class RenameIndividualsCollectionNumberToCollectorsFieldNumber < ActiveRecord::Migration[5.0]
  def change
    rename_column :individuals, :collection_nr, :collectors_field_number
  end
end
