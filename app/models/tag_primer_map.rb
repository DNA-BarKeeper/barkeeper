#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
class TagPrimerMap < ApplicationRecord
  include ProjectRecord

  belongs_to :ngs_run

  has_one_attached :tag_primer_map
  validates :tag_primer_map, attached: true, content_type: [:text, :csv] # Using only type text/csv leads to weird errors depending on file content

  after_save :set_name

  def set_name
    self.update_column(:name, tag_primer_map.filename.to_s.split('_')[1].split('.').first) if tag_primer_map.attached?
  end

  def check_tag_primer_map
    tpm_file = open_tag_primer_map

    return false unless tpm_file

    tp_map = CSV.read(tpm_file, { col_sep: "\t", headers: true })

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

  def revised_tag_primer_map(project_ids)
    tpm_file = open_tag_primer_map

    return nil unless tpm_file

    tp_map = CSV.read(tpm_file, { col_sep: "\t", headers: true })

    tp_map.each do |row|
      sample_id = row['#SampleID']

      next unless sample_id

      sample_id.match(/\D+\d+|\D+\z/)[0]

      isolate = Isolate.includes(individual: :taxon).find_by_lab_isolation_nr(sample_id)
      unless isolate
        isolate = Isolate.includes(individual: :taxon).create(lab_isolation_nr: sample_id)
        isolate.add_projects(project_ids)
        isolate.save
      end

      taxon = isolate&.individual&.taxon
      taxon_name = taxon.scientific_name.gsub(' ', '_') if taxon

      description = [sample_id]
      description << taxon_name if taxon_name
      description << row['TagID'] if row['TagID']
      description << row['Region'] if row['Region']

      row['Description'] = description.join('_')

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

  private

  def open_tag_primer_map
    require 'open-uri'

    begin
      open(tag_primer_map.service_url)
    rescue OpenURI::HTTPError # TPM file could not be found on server
      nil
    end
  end
end
