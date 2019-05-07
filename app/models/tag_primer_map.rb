class TagPrimerMap < ApplicationRecord
  include ProjectRecord

  belongs_to :ngs_run

  has_attached_file :tag_primer_map
  validates_attachment_content_type :tag_primer_map, content_type: 'text/plain' # Using type text/csv leads to weird errors depending on file content
  validates_attachment_file_name :tag_primer_map, :matches => [/txt\Z/, /csv\Z/]

  after_save :set_name

  def set_name
    self.update_column(:name, tag_primer_map_file_name.split('_').last.split('.').first) if tag_primer_map_file_name
  end

  def check_tag_primer_map
    tp_map = CSV.read(tag_primer_map.url, { col_sep: "\t", headers: true }) if tag_primer_map.url

    # Check if file is actually of type CSV
    valid = tp_map.instance_of?(CSV::Table)

    # Check if tag primer map has correct headers
    expected_headers = ["#SampleID", "BarcodeSequence", "LinkerPrimerSequence", "ReversePrimer", "Region"]
    valid &&= (expected_headers - tp_map.headers).empty? # Allows optional columns

    # Check if at least one row with data exists
    valid &&= tp_map.size.positive?

    # Check if only valid characters occur in data
    valid &&= tp_map['#SampleID'].find { |s| /[^A-Za-z0-9-]+/ =~ s }.blank? # Only letters, numbers and minus are allowed
    valid &&= tp_map['BarcodeSequence'].find { |s| /[^A-Za-z]+/ =~ s }.blank? # Only letters are allowed
    valid &&= tp_map['LinkerPrimerSequence'].find { |s| /[^A-Za-z]+/ =~ s }.blank?
    valid &&= tp_map['ReversePrimer'].find { |s| /[^A-Za-z]+/ =~ s }.blank?

    valid
  end

  def revised_tag_primer_map
    tp_map = CSV.read(tag_primer_map.url, { col_sep: "\t", headers: true })

    tp_map.each do |row|
      sample_id = row['#SampleID'].match(/\D+\d+|\D+\z/)[0]
      isolate = Isolate.joins(individual: :species).find_by_lab_nr(sample_id)

      if isolate
        species = isolate.individual.species.composed_name.gsub(' ', '_')
        row['Description'] = [sample_id, species, row['TagID'], row['Region']].join('_')
      else
        row['Description'] = [sample_id, row['TagID'], row['Region']].join('_')
      end

      # Adding indices to the region to indicate differing primer pairs, not necessary right now
      # region = row['Region']
      # primer_pairs = find_region_indices(tp_map)
      # next if primer_pairs[region].size < 2
      # primer_pair = [row['LinkerPrimerSequence'], row['ReversePrimer']]
      # row['Region'] = region + '_' + (primer_pairs[region].index(primer_pair) + 1).to_s
    end

    tp_map
  end

  # def find_region_indices(tp_map)
  #   primer_pairs = {}
  #
  #   tp_map['LinkerPrimerSequence'].each_with_index do |linker_primer, index|
  #     region = tp_map['Region'][index]
  #     primer_pair = [linker_primer, tp_map['ReversePrimer'][index]]
  #     existing_pairs = primer_pairs[region]
  #
  #     if existing_pairs
  #       next if existing_pairs.include? primer_pair
  #
  #       primer_pairs[region] << primer_pair
  #     else
  #       primer_pairs[region] = [primer_pair]
  #     end
  #   end
  #
  #   primer_pairs
  # end
end
