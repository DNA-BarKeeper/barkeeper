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

class AddHerbariumToIndividuals < ActiveRecord::Migration
  def change
    add_column :individuals, :herbarium, :string
    add_column :individuals, :voucher, :string
    add_column :individuals, :country, :string
    add_column :individuals, :state_province, :string
    add_column :individuals, :locality, :text
    add_column :individuals, :latitude, :string
    add_column :individuals, :longitude, :string
    add_column :individuals, :elevation, :string
    add_column :individuals, :exposition, :string
    add_column :individuals, :habitat, :text
    add_column :individuals, :substrate, :string
    add_column :individuals, :life_form, :string
    add_column :individuals, :collection_nr, :string
    add_column :individuals, :collection_date, :string
    add_column :individuals, :determination, :string
    add_column :individuals, :revision, :string
    add_column :individuals, :confirmation, :string
    add_column :individuals, :comments, :text
  end
end
