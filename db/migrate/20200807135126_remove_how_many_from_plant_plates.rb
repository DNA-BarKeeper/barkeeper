class RemoveHowManyFromPlantPlates < ActiveRecord::Migration[5.2]
  def change
    remove_column :plant_plates, :how_many, :integer
  end
end
