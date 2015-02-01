class AddLocationInRackToPlantPlate < ActiveRecord::Migration
  def change
    add_column :plant_plates, :location_in_rack, :string
  end
end
