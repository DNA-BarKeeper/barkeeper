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

class AddAttributesToMarkerSequenceSearch < ActiveRecord::Migration[5.0]
  def up
    add_column :marker_sequence_searches, :user_id, :integer
    add_column :marker_sequence_searches, :title, :string
    add_column :marker_sequence_searches, :family, :string
    add_column :marker_sequence_searches, :marker, :integer
    add_column :marker_sequence_searches, :min_length, :integer
    add_column :marker_sequence_searches, :max_length, :integer
  end

  def down
    remove_column :marker_sequence_searches, :user_id, :integer
    remove_column :marker_sequence_searches, :title, :string
    remove_column :marker_sequence_searches, :family, :string
    remove_column :marker_sequence_searches, :marker, :integer
    remove_column :marker_sequence_searches, :min_length, :integer
    remove_column :marker_sequence_searches, :max_length, :integer
  end
end
