class RenameIndividualHerbariumColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :individuals, :herbarium, :herbarium_code
  end
end
