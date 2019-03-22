class NgsRun < ApplicationRecord
  include ProjectRecord

  validates_presence_of :name

  belongs_to :higher_order_taxon
  has_many :tag_primer_maps
  has_many :clusters
  has_many :ngs_results
  has_many :isolates, through: :clusters

  has_attached_file :fastq
  has_attached_file :set_tag_map
  has_attached_file :results

  validates_attachment_content_type :fastq, content_type: 'text/plain' # Using 'chemical/seq-na-fastq' does not work reliably
  validates_attachment_content_type :set_tag_map, content_type: 'text/plain'
  validates_attachment_content_type :results, content_type: 'application/zip'

  validates_attachment_file_name :fastq, :matches => [/fastq\Z/, /fq\Z/, /fastq.gz\Z/, /fq.gz\Z/]
  validates_attachment_file_name :set_tag_map, :matches => /fasta\Z/
  validates_attachment_file_name :results, :matches => /zip\Z/

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
    # TODO: name all files after analysis name given by user before sending them

    packages_csv = CSV.open('path', 'w', col_sep: "\t")

    tag_primer_maps.each do |tag_primer_map|
      tpm = tag_primer_map.add_description # TODO ???

      packages_csv << [tag_primer_map.name, tag_primer_map.tag]
    end

    packages_csv.close

    #TODO: do stuff with updated tpm and packages csv
    #TODO: set default values for analysis parameters?

    # self.name = fastq_file_name.remove('.fasta')

    # Start analysis on xylocalyx

    # TODO: Check regularly somehow: e.g. process/script still running? results.zip present?)
    check_results
  end

  def check_results
    analysis_dir = "/data/data2/lara/Barcoding/#{self.name}_out.zip"

    Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx', '/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
      sftp.stat(analysis_dir) do |response|
        if response.ok?
          # Download result file
          sftp.download!("/data/data2/lara/Barcoding/#{self.name}_out.zip", "#{Rails.root}/#{self.name}_out.zip")
          import
        end
      end
    end
  end

  def import
    # Store results on AWS
    self.results = File.open("#{Rails.root}/#{self.name}_out.zip")

    # Unzip results
    Zip::File.open("#{Rails.root}/#{self.name}_out.zip") do |zip_file|
      zip_file.each do |entry|
        entry.extract("#{Rails.root}/#{entry.name}")
      end
    end

    # Import data
    Marker.gbol_marker.each do |marker|
      import_clusters(marker)
    end

    import_analysis_stats

    import_results

    self.save

    # Remove temporary files from server
    FileUtils.rm_r("#{Rails.root}/#{self.name}_out.zip")
    FileUtils.rm_r("#{Rails.root}/#{self.name}_out")
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
          isolate = Isolate.find_by_lab_nr(isolate_name)
          isolate ||= Isolate.create(lab_nr: isolate_name)

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

      case line_parts[0]
      when "Seqs pre-filtering"
        self.sequences_pre = line_parts[1].to_i
      when "Seqs post-seqtk-filtering"
        self.sequences_filtered = line_parts[1].to_i
      when "Seqs post-qiimelike-filtering (highQual)"
        self.sequences_high_qual = line_parts[1].to_i
      when "Seqs w/o 2nd primer"
        self.sequences_one_primer = line_parts[1].to_i
      else
        next
      end
    end
  end

  def import_results
    results = CSV.read("#{Rails.root}/#{self.name}_out/tagPrimerMap_expanded.txt", headers:true, col_sep: "\t")

    results.each do |result|
      id_split = result['#SampleID'].split('_')

      isolate = Isolate.find_by_lab_nr(id_split[0])
      marker = Marker.find_by_name(id_split[1])

      ngs_result = NgsResult.create(hq_sequences: result['HighQualSeqs'].to_i,
                                    incomplete_sequences: result['LinkerPrimerOnly'].to_i,
                                    cluster_count: result['Clusters'].to_i)
      ngs_result.isolate = isolate if isolate
      ngs_result.marker = marker if marker
      ngs_result.ngs_run = self

      ngs_result.save
    end
  end
end
