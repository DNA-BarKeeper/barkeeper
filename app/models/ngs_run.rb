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

class NgsRun < ApplicationRecord
  require 'open-uri'

  include PgSearch::Model
  include ProjectRecord

  validates_presence_of :name
  validates :name, uniqueness: true

  belongs_to :taxon
  has_many :tag_primer_maps, dependent: :destroy
  has_many :clusters, dependent: :destroy
  has_many :ngs_results, dependent: :destroy
  has_many :isolates, through: :clusters
  has_many :markers, through: :ngs_results
  has_many :issues, dependent: :destroy

  has_one_attached :set_tag_map
  validates :set_tag_map, content_type: [:text, 'application/octet-stream']

  has_one_attached :results
  validates :results, content_type: :zip

  multisearchable against: [:comment, :name]

  after_save :parse_package_map

  def parse_package_map
    if set_tag_map.attached?
      fasta_temp = Tempfile.open { |tempfile| tempfile << set_tag_map.download }
      Bio::FlatFile.open(fasta_temp.path).each_entry do |entry|
        tag_primer_maps.where(name: entry.definition)&.first&.update(tag: entry.seq)
      end
    end
  end

  def taxon_name
    self.try(:taxon)&.scientific_name
  end

  def taxon_name=(scientific_name)
    if name == ''
      self.taxon = nil
    else
      self.taxon = Taxon.find_by(scientific_name: scientific_name)
    end
  end

  # Check if all samples exist in app database
  def samples_exist
    nonexistent = []
    tag_primer_maps.each do |tp_map|
      if tp_map.tag_primer_map.attached?
        begin
          tpm_file = Tempfile.open { |tempfile| tempfile << tp_map.tag_primer_map.download }
          tp_map = CSV.read(tpm_file, { col_sep: "\t", headers: true })
          nonexistent << tp_map['#SampleID'].select { |id| !Isolate.exists?(lab_isolation_nr: id.match(/\D+\d+|\D+\z/)[0]) }
        rescue OpenURI::HTTPError
        end
      else
        nonexistent << "No file for Tag Primer Map #{tp_map.name} could be found on the server."
      end
    end

    nonexistent.flatten!

    size = nonexistent.size

    if size > 15
      nonexistent = nonexistent.first(15)
      nonexistent << "[... and #{size - 15} more]"
    end

    nonexistent
  end

  def check_tag_primer_map_count
    # Check if the correct number of TPMs was uploaded
    if set_tag_map.attached?
      begin
        package_cnt = set_tag_map.download.count('>')
        valid = (package_cnt == tag_primer_maps.size) && package_cnt.positive?
      rescue OpenURI::HTTPError
        return false
      end
    else
      valid = (tag_primer_maps.size == 1)
    end

    # Check if each Tag Primer Map is valid
    tag_primer_maps.each { |tpm| valid &&= tpm.check_tag_primer_map }

    valid
  end

  def run_pipe
    Net::SSH.start(ENV['REMOTE_SERVER_PATH'], ENV['REMOTE_USER'], keys: remote_key_list) do |session|
      analysis_dir = "#{ENV['BARCODING_PIPE_RESULTS_PATH']}/#{name}"
      output_dir = "#{ENV['BARCODING_PIPE_RESULTS_PATH']}/#{name}_out"

      # Create analysis directory (and remove older versions)
      session.exec!("rm -R #{analysis_dir}")
      session.exec!("mkdir #{analysis_dir}")

      # Write and uplaod adapter platepool (set tag map) file
      if set_tag_map.attached?
        File.open("#{Rails.root}/#{set_tag_map.filename}", 'w') do |file|
          file << set_tag_map.download
        end

        set_tag_map_path = "#{analysis_dir}/#{set_tag_map.filename}"
        session.scp.upload! "#{Rails.root}/#{set_tag_map.filename}", set_tag_map_path
      end

      # Write and upload edited tag primer maps
      tag_primer_maps.each do |tag_primer_map|
        tpm_filename = tag_primer_map.tag_primer_map.filename

        File.open("#{Rails.root}/#{tpm_filename}", 'w') do |file|
          file << tag_primer_map.revised_tag_primer_map(projects.map(&:id))
        end

        session.scp.upload! "#{Rails.root}/#{tpm_filename}", "#{analysis_dir}/#{tpm_filename}"
      end

      # Start analysis on server
      start_command = "ruby #{ENV['BARCODING_PIPE_PATH']}"
      start_command << "-s #{analysis_dir}/#{set_tag_map.filename} " if set_tag_map.attached? # Path to adapter platepool file on server
      tag_primer_maps.each do |tag_primer_map|
        start_command << "-m #{"#{analysis_dir}/#{tag_primer_map.tag_primer_map.filename}"} " # Path to tag primer map on server
      end
      start_command << "-w \"#{fastq_location}\" " # WebDAV address of raw analysis files
      start_command << "-o #{output_dir} " # Output directory
      start_command << "-d #{self.id} "
      start_command << "-t #{taxon.scientific_name} " if self.taxon
      start_command << "-q #{self.quality_threshold} "
      start_command << "-p #{self.primer_mismatches} " if self.primer_mismatches && self.primer_mismatches != 0.0
      start_command << "-b #{self.tag_mismatches} "

      session.exec!(start_command)

      # Remove edited tag primer maps and set tag map
      tag_primer_maps.each do |tag_primer_map|
        FileUtils.rm("#{Rails.root}/#{tag_primer_map.tag_primer_map.filename}")
      end

      FileUtils.rm("#{Rails.root}/#{set_tag_map.filename}") if set_tag_map.attached?
    end
  end

  def import(results_path)
    # Download results from remote server (action will be called at end of analysis script!)
    Net::SFTP.start(ENV['REMOTE_SERVER_PATH'], ENV['REMOTE_USER'], keys: remote_key_list) do |sftp|
      sftp.stat(results_path) do |response|
        if response.ok?
          # Delete older results
          results.purge
          Cluster.where(ngs_run_id: id).delete_all
          NgsResult.where(ngs_run_id: id).delete_all
          FileUtils.rm_r("#{Rails.root}/#{self.name}_out.zip") if File.exists?("#{Rails.root}/#{self.name}_out.zip")
          FileUtils.rm_r("#{Rails.root}/#{self.name}_out") if File.exists?("#{Rails.root}/#{self.name}_out")

          # Download result file
          sftp.download!(results_path, "#{Rails.root}/#{self.name}_out.zip")

          #TODO: Maybe add possibility to use AWS copy here in case of a reimport of data at a later point

          # Unzip results
          Zip::File.open("#{Rails.root}/#{self.name}_out.zip") do |zip_file|
            zip_file.each do |entry|
              entry.extract("#{Rails.root}/#{entry.name}")
            end
          end

          # Import data
          Marker.all.each do |marker|
            begin
              import_clusters(marker)
            rescue
              self.issues << Issue.create(title: "Import error",
                                       description: "Something went wrong when importing clusters for marker #{marker.name}")
            end
          end

          import_analysis_stats

          tag_primer_maps.each do |tpm|
            begin
              import_results("#{tpm.tag_primer_map.filename.to_s.gsub('.txt', '')}_expanded.txt")
            rescue Exception => e
              self.issues << Issue.create(title: "Import error",
                                       description: "Importing results for tag primer map #{tpm.tag_primer_map.filename}
                                                     resulted in error:\n#{e.message}")
            end
          end

          # Store results on AWS
          self.results.attach(io: File.open("#{Rails.root}/#{self.name}_out.zip"), filename: "#{self.name}_out.zip", content_type: 'application/zip')
          save!

          # Remove temporary files from server
          FileUtils.rm_r("#{Rails.root}/#{self.name}_out.zip")
          FileUtils.rm_r("#{Rails.root}/#{self.name}_out")
        else
          self.issues << Issue.create(title: "Result file not found",
                                   description: "The requested result file could not be found on the server.")
        end
      end
    end
  end

  def import_clusters(marker)
    if File.exist?("#{Rails.root}/#{self.name}_out/#{marker.name}.fasta")
      puts "Importing results for #{marker.name}..."
      Bio::FlatFile.open(Bio::FastaFormat, "#{Rails.root}/#{self.name}_out/#{marker.name}.fasta") do |ff|
        ff.each do |entry|
          def_parts = entry.definition.split('|')
          next unless def_parts[1].include?('centroid')

          cluster_def = def_parts[1].match(/(\d+)\**\w*\((\d+)\)/)

          isolate_name = def_parts[0].split('_')[0]
          isolate = Isolate.find_by_lab_isolation_nr(isolate_name)
          isolate ||= Isolate.create(lab_isolation_nr: isolate_name)

          running_number = cluster_def[1].to_i
          sequence_count = cluster_def[2].to_i
          reverse_complement = def_parts.last.match(/\bRC\b/) ?  true : false
          cluster = Cluster.new(running_number: running_number, sequence_count: sequence_count, reverse_complement: reverse_complement)

          blast_taxonomy = def_parts[2]
          blast_e_value = def_parts[3]
          blast_hit = BlastHit.create(taxonomy: blast_taxonomy, e_value: blast_e_value)

          cluster.name = isolate_name + '_' + marker.name + '_' + running_number.to_s
          cluster.centroid_sequence = entry.seq
          cluster.ngs_run = self
          cluster.marker = marker
          cluster.blast_hit = blast_hit
          cluster.add_projects(self.projects.map(&:id))
          cluster.save

          isolate.add_projects(self.projects.map(&:id))
          isolate.clusters << cluster
          isolate.save
        end
      end
    end
  end

  def import_analysis_stats
    File.open("#{Rails.root}/#{self.name}_out/#{self.name}_log.txt").each do |line|
      line_parts = line.split(':')
      value = line_parts[1].to_i

      case line_parts[0]
      when "Seqs pre-filtering"
        self.sequences_pre = value
      when "Seqs post-seqtk-filtering"
        self.sequences_filtered = value
      when "Seqs post-qiimelike-filtering (highQual)"
        self.sequences_high_qual = value
      when "Seqs w/o 2nd primer"
        self.sequences_one_primer = value
      when "Seqs too short/too long"
        self.sequences_short = value
      else
        next
      end
    end
  end

  def import_results(tpm_file_name)
    results = CSV.read("#{Rails.root}/#{self.name}_out/#{tpm_file_name}", headers:true, col_sep: "\t")

    results.each do |result|
      sample_id = result['#SampleID'].match(/\D+\d+|\D+\z/)[0]

      isolate = Isolate.find_by_lab_isolation_nr(sample_id)
      marker = Marker.find_by_name(result['Region'])

      ngs_result = NgsResult.create(hq_sequences: result['HighQualSeqs'].to_i,
                                    incomplete_sequences: result['LinkerPrimerOnly'].to_i,
                                    cluster_count: result['Clusters'].to_i,
                                    total_sequences: result['TotalSequences'].to_i)
      ngs_result.isolate = isolate if isolate
      ngs_result.marker = marker if marker
      ngs_result.ngs_run = self

      ngs_result.save
    end
  end

  private

  def check_server_status
    Net::SSH.start(ENV['REMOTE_SERVER_PATH'], ENV['REMOTE_USER'], keys: remote_key_list) do |session|
      session.exec!("pgrep -f \"barcoding_pipe.rb\"")
    end
  end

  def remote_key_list
    if ENV['REMOTE_KEYS'].include?(';')
      ENV['REMOTE_KEYS'].split(';')
    else
      [ENV['REMOTE_KEYS']]
    end
  end
end
