# frozen_string_literal: true

class RenameXmlUploader < ActiveRecord::Migration[5.0]
  def self.up
    rename_table :xml_uploaders, :specimen_exporters
  end

  def self.down
    rename_table :specimen_exporters, :xml_uploaders
  end
end
