class AddAttachmentUploadedFileToTxtUploaders < ActiveRecord::Migration
  def self.up
    change_table :txt_uploaders do |t|
      t.attachment :uploaded_file
    end
  end

  def self.down
    remove_attachment :txt_uploaders, :uploaded_file
  end
end
