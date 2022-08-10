#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

# frozen_string_literal: true

class Primer < ApplicationRecord
  extend Import
  include PgSearch::Model
  include ProjectRecord

  belongs_to :marker
  has_many :primer_reads, dependent: :nullify

  validates_presence_of :name

  after_save :auto_assign_primer_reads if :saved_change_to_name?

  multisearchable against: [:alt_name, :author, :labcode, :name, :notes, :target_group]

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

  def auto_assign_primer_reads
    PrimerRead.search_partial_name(name).map(&:auto_assign)
  end
end
