class NgsRun < ApplicationRecord
  include ProjectRecord

  validates_presence_of :name

  belongs_to :higher_order_taxon

  has_attached_file :fastq
  has_attached_file :tag_primer_map

  validates_attachment_content_type :fastq, content_type: /\Aapplication\/octet-stream/
  validates_attachment_content_type :tag_primer_map, content_type: /\Atext\/plain/ # Using type text/csv leads to weird errors depending on file content

  def check_tag_primer_map
    tp_map = CSV.read(tag_primer_map.path, { col_sep: "\t", headers: true }) if tag_primer_map

    # Check if file is actually of type CSV
    valid = (tp_map.class == 'CSV::Table')

    # Check if tag primer map has correct headers
    expected_headers = ["#SampleID", "BarcodeSequence", "LinkerPrimerSequence", "ReversePrimer", "Region", "TagNumber"]
    valid &&= (tp_map.headers == expected_headers)

    # Check if at least one row with data exists
    valid &&= tp_map.size.positive?

    valid
  end

  # Check if all samples exist in app database
  def samples_exist
    tp_map = CSV.read(tag_primer_map.path, { col_sep: "\t", headers: true }) if tag_primer_map
    tp_map['#SampleID'].select { |id| !Isolate.exists?(lab_nr: id) }
  end

  def check_fastq
    # TODO: create method
    # Criteria: Anzahl Zeilen durch 4 teilbar, CCS file (header enthält 'ccs'), Header beginnt mit @
    true
  end

  def import_reads
    # TODO: create method

    # Add description column to tag primer map
    tp_map = CSV.read(tag_primer_map.path, { col_sep: "\t", headers: true })

    tp_map.each do |row|
      sample_id = row['#SampleID']
      species = Isolate.joins(individual: :species).find_by_lab_nr(sample_id).individual.species.composed_name.gsub(' ', '_')

      row['NewDescription'] = [sample_id, species, row['TagNumber'], row['Region']].join('_')
    end
  end
end
