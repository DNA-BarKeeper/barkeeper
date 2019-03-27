class NgsRun < ApplicationRecord
  include ProjectRecord

  validates_presence_of :name
  validates :name, uniqueness: true

  belongs_to :higher_order_taxon
  has_many :tag_primer_maps, dependent: :destroy
  has_many :clusters, dependent: :destroy
  has_many :ngs_results, dependent: :destroy
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
    nonexistent = []
    tag_primer_maps.each do |tp_map|
      tp_map = CSV.read(tp_map.tag_primer_map.path, { col_sep: "\t", headers: true })
      nonexistent << tp_map['#SampleID'].select { |id| !Isolate.exists?(lab_nr: id.match(/\D+\d+|\D+\z/)[0]) }
    end

    nonexistent.flatten!

    size = nonexistent.size

    if size > 15
      nonexistent = nonexistent.first(15)
      nonexistent << "[... and #{size - 15} more]"
    end

    nonexistent
  end

  def check_fastq
    if fastq.path
      valid = true
    else
      return false
    end

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

  def check_server_status
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx', '/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      session.exec!("pgrep -f \"barcoding_pipe.rb\"")
    end
  end

  def run_pipe
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx', '/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      analysis_dir = "/data/data1/sarah/ngs_barcoding/#{name}"
      output_dir = "/data/data1/sarah/ngs_barcoding/#{name}_out"

      # Write edited tag primer maps
      tag_primer_maps.each do |tag_primer_map|
        File.open("#{Rails.root}/#{tag_primer_map.tag_primer_map_file_name}", 'w') do |file|
          file << tag_primer_map.revised_tag_primer_map
        end
      end

      tag_primer_map_path = "#{analysis_dir}/#{tag_primer_maps.first.tag_primer_map_file_name}"
      fastq_path = "#{analysis_dir}/#{fastq_file_name}"

      # Create analysis directory
      session.exec!("mkdir #{analysis_dir}")

      # Upload analysis input files
      session.scp.upload! "#{Rails.root}/#{tag_primer_maps.first.tag_primer_map_file_name}", tag_primer_map_path
      session.scp.upload! fastq.path, fastq_path
      # session.scp.upload! fastq.url, fastq_path

      # Start analysis on server #TODO uncomment when ready
      # session.exec!("ruby /data/data2/lara/Barcoding/barcoding_pipe.rb -m #{tag_primer_map_path} -f #{fastq_path} -o #{output_dir}")

      # Remove edited tag primer maps
      tag_primer_maps.each do |tag_primer_map|
        FileUtils.rm("#{Rails.root}/#{tag_primer_map.tag_primer_map_file_name}")
      end
    end
  end

  def import
    # analysis_dir = "/data/data1/sarah/ngs_barcoding/#{name}_out.zip"
    analysis_dir = "/data/data2/lara/Barcoding/#{name}_out.zip" #TODO change when finished

    # Download results from Xylocalyx
    Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx', '/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
      sftp.stat(analysis_dir) do |response|
        if response.ok?
          # Download result file
          sftp.download!(analysis_dir, "#{Rails.root}/#{self.name}_out.zip")

          # Delete older results
          results.clear
          Cluster.where(ngs_run_id: id).delete_all
          NgsResult.where(ngs_run_id: id).delete_all

          #TODO: Maybe add possibility to use AWS copy here in case of a reimport of data at a later point
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

          # Store results on AWS
          update(results: File.open("#{Rails.root}/#{self.name}_out.zip"))
          save!

          # Remove temporary files from server
          FileUtils.rm_r("#{Rails.root}/#{self.name}_out.zip")
          FileUtils.rm_r("#{Rails.root}/#{self.name}_out")
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

  def import_results
    results = CSV.read("#{Rails.root}/#{self.name}_out/tagPrimerMap_expanded.txt", headers:true, col_sep: "\t")

    results.each do |result|
      sample_id = result['#SampleID'].match(/\D+\d+|\D+\z/)[0]

      isolate = Isolate.find_by_lab_nr(sample_id)
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
end
