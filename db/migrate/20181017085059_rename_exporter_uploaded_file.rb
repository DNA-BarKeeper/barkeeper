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

class RenameExporterUploadedFile < ActiveRecord::Migration[5.0]
  def self.rename_attachment(table, old, new)
    attachment_columns = [['file_name', :string], ['content_type', :string], ['file_size', :integer], ['updated_at', :datetime]]

    attachment_columns.each do |suffix, _type|
      rename_column table, "#{old}_#{suffix}", "#{new}_#{suffix}"
    end
  end

  def self.up
    rename_attachment :species_exporters, :uploaded_file, :species_export
    rename_attachment :specimen_exporters, :uploaded_file, :specimen_export
  end

  def self.down
    rename_attachment :species_exporters, :species_export, :uploaded_file
    rename_attachment :specimen_exporters, :specimen_export, :uploaded_file
  end
end
