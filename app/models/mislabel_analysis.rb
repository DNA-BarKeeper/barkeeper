#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

# frozen_string_literal: true

class MislabelAnalysis < ApplicationRecord
  belongs_to :marker
  has_many :mislabels, dependent: :destroy
  has_one :marker_sequence_search, dependent: :destroy
  has_and_belongs_to_many :marker_sequences

  def percentage_of_mislabels
    ((mislabels.size / total_seq_number.to_f) * 100).round(2) if total_seq_number&.positive?
  end

  def self.start_analysis
    Marker.all.each do | marker |
      if new_sequences?(marker)
        marker_name = marker.name
        project = Project.where('name like ?', 'All%').first
        search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker_name, project_id: project.id)

        title = "all_taxa_#{marker_name}_#{search.created_at.to_date}"
        mislabel_analysis = MislabelAnalysis.create(title: title,
                                                    automatic: true,
                                                    total_seq_number: search.marker_sequences.size,
                                                    marker: marker,
                                                    marker_sequence_search: search)

        if ENV['REMOTE_SERVER_PATH'] && server_available?
          mislabel_analysis.analyse_remotely
        else
          mislabel_analysis.analyse_locally
        end
      end
    end
  end

  private

  def self.new_sequences?(marker)
      last_analysis = MislabelAnalysis.where(automatic: true, marker: marker).order(created_at: :desc).first
      count = -1

      # Checking if new sequences for this marker exist
      if last_analysis
        count = MarkerSequence.where(marker_id: marker.id).where('marker_sequences.updated_at >= ?', last_analysis.created_at).size
      end

      ((count > 50) || (count == -1)) # More than 50 new seqs OR no analysis was done before
  end

  def analyse_locally
    analysis_dir = "#{Rails.root}/SATIVA_analyses/#{title}"

    # Create analysis directory
    system("mkdir #{analysis_dir}")

    sequences = "#{analysis_dir}/#{title}.fasta"
    tax_file = "#{analysis_dir}/#{title}.tax"

    File.open(sequences, 'w+') do |f|
      f.write(marker_sequence_search.analysis_fasta(true))
    end

    File.open(tax_file, 'w+') do |f|
      f.write(marker_sequence_search.taxon_file(true))
    end

    # Run MAFFT to create an alignment
    alignment = "#{analysis_dir}/#{title}_mafft.fasta"
    system("mafft --thread 10 --maxiterate 1000 #{sequences} > #{alignment}")

    # Run SATIVA (only takes file names, not paths!)
    system("cd #{analysis_dir}")
    system("python #{ENV['SATIVA_PATH']} -s #{alignment} -t #{tax_file} -x BOT -T 10") # TODO Replace BOT

    results = "#{analysis_dir}/#{title}.mis"

    if File.exist?(results)
      import(results)

      # Remove last automated analysis for this marker from web app
      last_analysis = MislabelAnalysis.where(automatic: true, marker: marker_sequence_search.marker).order(created_at: :desc).last
      last_analysis.destroy unless last_analysis.id == id # Avoid self-destruct!
    end
  end

  def remote_key_list
    if ENV['REMOTE_KEYS'].include?(';')
      ENV['REMOTE_KEYS'].split(';')
    else
      [ENV['REMOTE_KEYS']]
    end
  end

  # Check if SATIVA is already running on the server
  def server_available?
    Net::SSH.start(ENV['REMOTE_SERVER_PATH'], ENV['REMOTE_USER'], keys: remote_key_list) do |session|
      return session.exec!("pgrep -f \"sativa.py\"").empty? # TODO: Check if this is actually the process name
    end
  end

  # Start a SATIVA mislabel analysis
  def analyse_remotely
    Net::SSH.start(ENV['REMOTE_SERVER_PATH'], ENV['REMOTE_USER'], keys: remote_key_list) do |session|
      local_analysis_dir = "#{Rails.root}/SATIVA_analyses/#{title}"

      sequences = "#{local_analysis_dir}/#{title}.fasta"
      tax_file = "#{local_analysis_dir}/#{title}.tax"

      File.open(sequences, 'w+') do |f|
        f.write(marker_sequence_search.analysis_fasta(true))
      end

      File.open(tax_file, 'w+') do |f|
        f.write(marker_sequence_search.taxon_file(true))
      end

      # Create remote analysis directory
      analysis_dir = "#{ENV['SATIVA_RESULTS_PATH']}/#{title}"
      session.exec!("mkdir #{analysis_dir}")

      # Upload analysis input files
      session.scp.upload! tax_file, analysis_dir
      session.scp.upload! sequences, analysis_dir

      # Run MAFFT to create an alignment
      alignment = "#{analysis_dir}/#{title}_mafft.fasta"
      session.exec!("mafft --thread 10 --maxiterate 1000 #{sequences} > #{alignment}")

      # Run SATIVA (only takes file names, not paths!)
      session.exec!("cd #{analysis_dir}")
      session.exec!("python #{ENV['SATIVA_PATH']} -s #{alignment} -t #{tax_file} -x BOT -T 10") # TODO Replace BOT

      # Download results
      download_results(analysis_dir, local_analysis_dir)

      # Import analysis results
      results_path = "#{local_analysis_dir}/#{title}.mis"
      if File.exist?(results_path)
        import(results_path)

        # Remove last automated analysis for this marker from web app
        last_analysis = MislabelAnalysis.where(automatic: true, marker: marker_sequence_search.marker).order(created_at: :desc).last
        last_analysis.destroy unless last_analysis.id == id # Avoid self-destruct!
      end
    end
  end

  # Check if recent SATIVA results exist and download them
  def download_results(remote_dir, local_dir)
    results_remote = "#{remote_dir}/#{title}.mis"
    results = "#{local_dir}/#{title}.mis"

    # Check if file exists before download
    Net::SFTP.start(ENV['REMOTE_SERVER_PATH'], ENV['REMOTE_USER'], keys: remote_key_list) do |sftp|
      sftp.stat(results_remote) do |response|
        if response.ok?
          sftp.download!(results_remote, results)
        end
      end
    end
  end

  # Import SATIVA result table (*.mis)
  def import(file)
    column_names = %w[SeqID MislabeledLevel OriginalLabel ProposedLabel
                      Confidence OriginalTaxonomyPath ProposedTaxonomyPath
                      PerRankConfidence]

    File.open(file, 'r').each do |row|
      next if row.start_with?(';')

      row = Hash[[column_names, row.split("\t")].transpose]

      mislabel = Mislabel.new
      mislabel.level = row['MislabeledLevel']
      mislabel.confidence = row['Confidence'].to_f
      mislabel.proposed_label = row['ProposedLabel']
      mislabel.proposed_path = row['ProposedTaxonomyPath']
      mislabel.path_confidence = row['PerRankConfidence']
      mislabel.save

      name = row['SeqID'].split('_')[0..1].join('_')
      marker_sequence = MarkerSequence.find_by_name(name)

      if marker_sequence
        marker_sequence.mislabels << mislabel

        mislabels << mislabel
        marker_sequences << marker_sequence
      end
    end
  end
end
