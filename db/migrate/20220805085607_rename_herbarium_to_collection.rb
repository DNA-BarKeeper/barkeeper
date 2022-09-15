class RenameHerbariumToCollection < ActiveRecord::Migration[5.2]
  def change
    rename_table :herbaria, :collections

    rename_column :individual_searches, :herbarium, :collection
    rename_column :individuals, :herbarium_id, :collection_id
  end
end
