# frozen_string_literal: true

class MislabelAnalysis < ApplicationRecord
  belongs_to :marker
  has_many :mislabels, dependent: :destroy
  has_one :marker_sequence_search
  has_and_belongs_to_many :marker_sequences

  def percentage_of_mislabels
    ((mislabels.size / total_seq_number.to_f) * 100).round(2) if total_seq_number&.positive?
  end

  def analyse_on_server
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      # Check if SATIVA.sh is already running
      running = session.exec!("pgrep -f \"SATIVA.sh\"")

      if running.empty?
        sequences = "#{Rails.root}/#{title}.fasta"
        tax_file = "#{Rails.root}/#{title}.tax"

        analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

        File.open(sequences, 'w+') do |f|
          f.write(marker_sequence_search.analysis_fasta(true))
        end

        File.open(tax_file, 'w+') do |f|
          f.write(marker_sequence_search.taxon_file(true))
        end

        # Create analysis directory
        session.exec!("mkdir #{analysis_dir}")

        # Upload analysis input files
        session.scp.upload! tax_file, analysis_dir
        session.scp.upload! sequences, analysis_dir

        # Delete local files
        FileUtils.rm(sequences)
        FileUtils.rm(tax_file)

        # Start analysis on server
        session.exec!("/home/kai/analysis-scripts/SATIVA.sh #{title} #{id}")
      end
    end
  end

  # Check if recent SATIVA results exist and download them
  def download_results
    exists = false
    analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

    # Check if file exists before download
    Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
      sftp.stat("#{analysis_dir}/#{title}.mis") do |response|
        if response.ok?
          # Download result file
          sftp.download!("#{analysis_dir}/#{title}.mis", "#{Rails.root}/#{title}.mis")
          exists = true
        end
      end
    end

    next unless exists

    # Import analysis result and then remove them
    results = File.new("#{Rails.root}/#{title}.mis")
    import(results)
    FileUtils.rm(results)
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
      if marker_sequence.nil? && name.start_with?('DB')
        marker_sequence = MarkerSequence.find_by_name(name.gsub('DB', 'DB '))
      end

      next unless marker_sequence

      marker_sequence.mislabels << mislabel

      mislabels << mislabel
      marker_sequences << marker_sequence
    end
  end
end
