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
# frozen_string_literal: true

class Primer < ApplicationRecord
  extend Import
  include ProjectRecord

  belongs_to :marker
  has_many :primer_reads

  validates_presence_of :name

  # Import primer data from spreadsheet
  def self.import(file, project_id)
    spreadsheet = Primer.open_spreadsheet(file)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      valid_keys = %w[alt_name sequence author name tm target_group] # Only direct attributes

      primer = Primer.find_or_create_by(name: row['name'].strip)
      primer.add_project(project_id)

      marker = Marker.find_or_create_by(name: row['marker'])
      marker.add_project_and_save(project_id)

      primer.marker_id = marker.id
      primer.reverse = (row['reverse'] == 'R')
      primer.attributes = row.to_hash.slice(*valid_keys)

      primer.save!
    end
  end
end
