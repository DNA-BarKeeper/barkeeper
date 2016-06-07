class AddAttachmentUploadedFileToSpeciesXmlUploaders < ActiveRecord::Migration
  def self.up
    change_table :species_xml_uploaders do |t|
      t.attachment :uploaded_file
    end
  end

  def self.down
    remove_attachment :species_xml_uploaders, :uploaded_file
  end
end
