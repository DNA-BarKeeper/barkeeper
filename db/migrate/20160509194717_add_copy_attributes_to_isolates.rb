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

class AddCopyAttributesToIsolates < ActiveRecord::Migration
  def change
    add_column :isolates, :lab_id_orig, :integer
    add_column :isolates, :lab_id_copy, :integer
    add_column :isolates, :isolation_date, :datetime
    add_column :isolates, :micronic_plate_id_orig, :integer
    add_column :isolates, :micronic_plate_id_copy, :integer
    add_column :isolates, :well_pos_micronic_plate_orig, :string
    add_column :isolates, :well_pos_micronic_plate_copy, :string
    add_column :isolates, :concentration_orig, :decimal
    add_column :isolates, :concentration_copy, :decimal
    add_column :isolates, :micronic_tube_id_orig, :string
    add_column :isolates, :micronic_tube_id_copy, :string
  end
end
