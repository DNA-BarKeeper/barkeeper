class CreateTxtUploaders < ActiveRecord::Migration
  def change
    create_table :txt_uploaders do |t|

      t.timestamps null: false
    end
  end
end
