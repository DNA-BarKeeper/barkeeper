class RenameSpeciesXmlUploader < ActiveRecord::Migration[5.0]
  def self.up
    rename_table :species_xml_uploaders, :species_exporters
  end

  def self.down
    rename_table :species_exporters, :species_xml_uploaders
  end
end
