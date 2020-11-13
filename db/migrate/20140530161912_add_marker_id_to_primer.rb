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

class AddMarkerIdToPrimer < ActiveRecord::Migration
  def change
    add_column :primers, :marker_id, :integer
    add_column :individuals, :species_id, :integer
    add_column :lab_racks, :freezer_id, :integer
    add_column :freezers, :lab_id, :integer
    add_column :copies, :tissue_id, :integer
    add_column :copies, :micronic_plate_id, :integer
    add_column :copies, :plant_plate_id, :integer
    add_column :primer_reads, :contig_id, :integer
    add_column :marker_sequences, :copy_id, :integer
    add_column :contigs, :marker_seq_id, :integer
  end
end
