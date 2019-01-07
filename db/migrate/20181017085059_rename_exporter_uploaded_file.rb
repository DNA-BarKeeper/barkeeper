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
