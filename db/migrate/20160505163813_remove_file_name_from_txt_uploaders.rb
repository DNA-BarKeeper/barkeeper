class RemoveFileNameFromTxtUploaders < ActiveRecord::Migration
  def change
    remove_column :txt_uploaders, :file_name
  end
end
