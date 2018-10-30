# frozen_string_literal: true

class Primer < ApplicationRecord
  extend Import
  include ProjectRecord

  belongs_to :marker
  has_many :primer_reads
  has_many :primer_pos_on_genomes

  validates_presence_of :name

  def self.import(file, project_id)
    spreadsheet = Primer.open_spreadsheet(file)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      valid_keys = %w[alt_name sequence author name tm target_group] # Only direct attributes; associations are extra:

      # Update existing spp or create new
      primer = Primer.find_or_create_by(name: row['name'].strip)

      # Add marker or assign to existing:
      marker = Marker.find_or_create_by(name: row['marker'])
      marker.add_project_and_save(project_id)

      primer.marker_id = marker.id

      # Add orientation
      primer.reverse = (row['reverse'] == 'R')

      primer.attributes = row.to_hash.slice(*valid_keys)

      primer.add_project(project_id)

      primer.save!
    end
  end
end
