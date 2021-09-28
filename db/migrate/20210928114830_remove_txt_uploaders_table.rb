class RemoveTxtUploadersTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :txt_uploaders
  end
end
