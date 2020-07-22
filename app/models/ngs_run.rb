class NgsRun < ApplicationRecord
  include ProjectRecord

  validates_presence_of :name
  validates :name, uniqueness: true

  belongs_to :higher_order_taxon
  has_many :tag_primer_maps, dependent: :destroy
  has_many :clusters, dependent: :destroy
  has_many :ngs_results, dependent: :destroy
  has_many :isolates, through: :clusters
  has_many :markers, through: :ngs_results
  has_many :issues

  has_one_attached :set_tag_map
  has_one_attached :results

  # validates_attachment_content_type :set_tag_map, content_type: 'text/plain'
  # validates_attachment_content_type :results, content_type: 'application/zip'
  #
  # validates_attachment_file_name :set_tag_map, :matches => /fasta\Z/
  # validates_attachment_file_name :results, :matches => /zip\Z/

  attr_accessor :delete_set_tag_map
  before_validation :remove_set_tag_map

  after_save :parse_package_map

  def remove_set_tag_map
    if delete_set_tag_map == '1'
      set_tag_map.purge
      tag_primer_maps.offset(1).destroy_all
    end
  end

  def parse_package_map
    if set_tag_map.attached?
      begin
        package_map_file = open(set_tag_map.service_url)
        package_map = Bio::FastaFormat.open(package_map_file)
        package_map.each do |entry|
          tag_primer_maps.where(name: entry.definition)&.first&.update(tag: entry.seq)
        end
      rescue OpenURI::HTTPError
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
      if tp_map.tag_primer_map.attached?
        begin
          tpm_file = open(tp_map.tag_primer_map.service_url)
          tp_map = CSV.read(tpm_file, { col_sep: "\t", headers: true })
          nonexistent << tp_map['#SampleID'].select { |id| !Isolate.exists?(lab_isolation_nr: id.match(/\D+\d+|\D+\z/)[0]) }
        rescue OpenURI::HTTPError
        end
      else
        nonexistent << "No file for Tag Primer Map #{tp_map.name} could not be found."
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
        set_tag_map_file = open(set_tag_map.service_url)
        package_cnt = Bio::FastaFormat.open(set_tag_map_file).entries.size
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
        File.open("#{Rails.root}/#{tag_primer_map.tag_primer_map.filename}", 'w') do |file|
          file << tag_primer_map.revised_tag_primer_map(projects.map(&:id))
        end
      end

      tag_primer_map_path = "#{analysis_dir}/#{tag_primer_maps.first.tag_primer_map.filename}"

      # Create analysis directory
      session.exec!("mkdir #{analysis_dir}")

      # Upload analysis input files
      session.scp.upload! "#{Rails.root}/#{tag_primer_maps.first.tag_primer_map.filename}", tag_primer_map_path

      # Start analysis on server # TODO uncomment when ready and add remaining parameters
      # session.exec!("ruby /data/data2/lara/Barcoding/barcoding_pipe.rb -m #{tag_primer_map_path} -f #{fastq_location} -o #{output_dir}")

      # Remove edited tag primer maps
      tag_primer_maps.each do |tag_primer_map|
        FileUtils.rm("#{Rails.root}/#{tag_primer_map.tag_primer_map.filename}")
      end
    end
  end

  def import(results_path)
    # Download results from Xylocalyx (action will be called at end of analysis script on Xylocalyx!)
    Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx', '/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
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
              self.issues << Issue.new(title: "Import error",
                                       description: "Something went wrong when importing clusters for marker #{marker.name}")
            end
          end

          import_analysis_stats

          tag_primer_maps.each do |tpm|
            begin
              import_results("#{tpm.tag_primer_map.filename.gsub('.txt', '')}_expanded.txt")
            rescue Exception => e
              self.issues << Issue.new(title: "Import error",
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
          self.issues << Issue.new(title: "Result file not found",
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
end
