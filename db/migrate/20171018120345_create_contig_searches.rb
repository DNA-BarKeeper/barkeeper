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

class CreateContigSearches < ActiveRecord::Migration[5.0]
  def up
    create_table :contig_searches do |t|
      t.string :species
      t.integer :order_id
      t.decimal :min_age
      t.decimal :max_age
      t.decimal :min_update
      t.decimal :max_update
      t.string :specimen
      t.string :family
      t.boolean :verified
      t.integer :marker_id
      t.string :name
      t.boolean :assembled

      t.timestamps
    end
  end

  def down
    drop_table :contig_searches
  end
end
