class RemoveHerbariumCodeFromIndividuals < ActiveRecord::Migration[5.2]
  def change
    remove_column :individuals, :herbarium_code
  end
end
