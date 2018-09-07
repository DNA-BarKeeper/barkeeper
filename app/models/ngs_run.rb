class NgsRun < ApplicationRecord
  include ProjectRecord

  validates_presence_of :name

  belongs_to :higher_order_taxon
  has_many :tag_primer_maps

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
    package_cnt = Bio::FastaFormat.open(set_tag_map.path).entries.size if set_tag_map.path

    # Check if the correct number of TPMs was uploaded
    valid = (package_cnt == tag_primer_maps.size) && package_cnt.positive?

    # Check if each Tag Primer Map is valid
    tag_primer_maps.each { |tpm| valid &&= tpm.check_tag_primer_map }

    valid
  end

  def run_pipe
    packages_csv = CSV.open('path', 'w', col_sep: "\t")

    tag_primer_maps.each do |tag_primer_map|
      tpm = tag_primer_map.add_description

      packages_csv << [tag_primer_map.name, tag_primer_map.tag]
    end

    packages_csv.close

    #TODO do stuff with updated tpm and packages csv
  end

  def import
    run_pipe

    # Import results
  end
end
