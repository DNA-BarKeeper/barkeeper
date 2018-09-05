class TagPrimerMap < ApplicationRecord
  include ProjectRecord

  belongs_to :ngs_run

  has_attached_file :tag_primer_map

  validates_attachment_content_type :tag_primer_map, content_type: 'text/plain' # Using type text/csv leads to weird errors depending on file content

  validates_attachment_file_name :tag_primer_map, :matches => [/txt\Z/, /csv\Z/]

  attr_accessor :delete_tag_primer_map
  before_validation { tag_primer_map.clear if delete_tag_primer_map == '1' }

  def check_tag_primer_map
    tp_map = CSV.read(tag_primer_map.path, { col_sep: "\t", headers: true }) if tag_primer_map.path

    # Check if file is actually of type CSV
    valid = tp_map.instance_of?(CSV::Table)

    # Check if tag primer map has correct headers
    expected_headers = ["#SampleID", "BarcodeSequence", "ForwardPrimerSequence", "ReversePrimer", "TagID", "Region", "Description"]
    valid &&= (tp_map.headers == expected_headers)

    # Check if at least one row with data exists
    valid &&= tp_map.size.positive?

    valid
  end
end
