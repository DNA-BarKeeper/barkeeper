class AddLabRackToPlantPlate < ActiveRecord::Migration[5.0]
  def change
    add_reference :plant_plates, :lab_rack, foreign_key: true
  end
end
