class AddFilenameToTxtUploaders < ActiveRecord::Migration
  def change
    add_column :txt_uploaders, :file_name, :string
  end
end