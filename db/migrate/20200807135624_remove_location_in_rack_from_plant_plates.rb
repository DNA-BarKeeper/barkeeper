class RemoveLocationInRackFromPlantPlates < ActiveRecord::Migration[5.2]
  def change
    remove_column :plant_plates, :location_in_rack, :string
  end
end
