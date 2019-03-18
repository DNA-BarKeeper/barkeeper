class NgsRun < ApplicationRecord
  include ProjectRecord

  validates_presence_of :analysis_name

  belongs_to :higher_order_taxon
  has_many :tag_primer_maps
  has_many :clusters
  has_many :isolates

  has_attached_file :fastq
  has_attached_file :set_tag_map

  validates_attachment_content_type :fastq, content_type: 'text/plain' # Using 'chemical/seq-na-fastq' does not work reliably
  validates_attachment_content_type :set_tag_map, content_type: 'text/plain'

  validates_attachment_file_name :fastq, :matches => [/fastq\Z/, /fq\Z/, /fastq.gz\Z/, /fq.gz\Z/]
  validates_attachment_file_name :set_tag_map, :matches => /fasta\Z/

  attr_accessor :delete_fastq
  before_validation { fastq.clear if delete_fastq == '1' }

  attr_accessor :delete_set_tag_map
  before_validation :remove_set_tag_map

  after_save :parse_package_map

  def remove_set_tag_map
    if delete_set_tag_map == '1'
      set_tag_map.clear
      tag_primer_maps.offset(1).destroy_all
    end
  end

  def parse_package_map
    if set_tag_map.path
      package_map = Bio::FastaFormat.open(set_tag_map.path)
      package_map.each do |entry|
        tag_primer_maps.where(name: entry.definition)&.first&.update(tag: entry.seq)
      end
    end
  end

  def remove_tag_primer_maps(checked_values)
    checked_values.values.each { |id| TagPrimerMap.find(id).destroy unless id == '0' }
  end

  # Check if all samples exist in app database
  def samples_exist
    tp_map = CSV.read(tag_primer_map.path, { col_sep: "\t", headers: true }) if tag_primer_map
    tp_map['#SampleID'].select { |id| !Isolate.exists?(lab_nr: id) } # TODO: Maybe shorten list if necessary
  end

  def check_fastq
    valid = true if fastq.path

    line_count = `wc -l "#{fastq.path}"`.strip.split(' ')[0].to_i
    valid &&= (line_count % 4).zero? # Number of lines is a multiple of 4

    header = File.open(fastq.path, &:readline).strip

    valid &&= header[0] == '@' # Header beginnt mit @

    valid &&= header.include?('ccs') # Header enthält 'ccs' (file ist ccs file)

    valid
  end

  def check_tag_primer_maps
    # Check if the correct number of TPMs was uploaded
    if set_tag_map.path
      package_cnt = Bio::FastaFormat.open(set_tag_map.path).entries.size
      valid = (package_cnt == tag_primer_maps.size) && package_cnt.positive?
    else
      valid = (tag_primer_maps.size == 1)
    end

    # Check if each Tag Primer Map is valid
    tag_primer_maps.each { |tpm| valid &&= tpm.check_tag_primer_map }

    valid
  end

  def run_pipe
    # TODO: name all files after analysis_name given by user before sending them

    packages_csv = CSV.open('path', 'w', col_sep: "\t")

    tag_primer_maps.each do |tag_primer_map|
      tpm = tag_primer_map.add_description

      packages_csv << [tag_primer_map.name, tag_primer_map.tag]
    end

    packages_csv.close

    #TODO: do stuff with updated tpm and packages csv
    #TODO: set default values for analysis parameters?

    # self.analysis_name = fastq_file_name.remove('.fasta')

    # Start analysis on xylocalyx

    # TODO: Check regularly somehow: e.g. process/script still running? results.zip present?)
    # TODO: Use actual current project ID
    check_results(5)
  end

  def check_results(project_id)
    analysis_dir = "/data/data2/lara/Barcoding/#{self.analysis_name}_out.zip"

    Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx', '/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
      sftp.stat(analysis_dir) do |response|
        if response.ok?
          # Download result file
          sftp.download!("/data/data2/lara/Barcoding/#{self.analysis_name}_out.zip", "#{Rails.root}/#{self.analysis_name}_out.zip")
          import(project_id)
        end
      end
    end
  end

  def import(project_id)
    # TODO: send results to AWS storage

    # Unzip results
    Zip::File.open("#{Rails.root}/#{self.analysis_name}_out.zip") do |zip_file|
      zip_file.each do |entry|
        entry.extract("#{Rails.root}/#{entry.name}")
      end
    end

    # Import results for each marker
    Marker.gbol_marker.each do |marker|
      if File.exist?("#{Rails.root}/#{self.analysis_name}_out/#{marker.name}.fasta")
        puts "Importing results for #{marker.name}..."
        Bio::FlatFile.open(Bio::FastaFormat, "#{Rails.root}/#{self.analysis_name}_out/#{marker.name}.fasta") do |ff|
          ff.each do |entry|
            def_parts = entry.definition.split('|')
            next unless def_parts[1].include?('centroid')

            cluster_def = def_parts[1].match(/(\d+)\**\w*\((\d+)\)/)

            isolate_name = def_parts[0].split('_')[0]
            isolate = Isolate.find_by_lab_nr(isolate_name)
            isolate ||= Isolate.create(lab_nr: isolate_name)

            running_number = cluster_def[1].to_i
            sequence_count = cluster_def[2].to_i
            reverse_complement = def_parts.last.match(/\bRC\b/) ?  true : false
            cluster = Cluster.new(running_number: running_number, sequence_count: sequence_count, reverse_complement: reverse_complement)

            cluster.name = isolate_name + '_' + marker.name + '_' + running_number.to_s
            cluster.centroid_sequence = entry.seq
            cluster.ngs_run = self
            cluster.marker = marker
            cluster.save

            isolate.add_project(project_id)
            isolate.clusters << cluster
            isolate.save

            #TODO: Add project ID to clusters?
          end
        end
      end
    end

    # Remove temporary files from server
    FileUtils.rm_r("#{Rails.root}/#{self.analysis_name}_out.zip")
    FileUtils.rm_r("#{Rails.root}/#{self.analysis_name}_out")
  end
end
