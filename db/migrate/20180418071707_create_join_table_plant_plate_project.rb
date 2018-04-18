class CreateJoinTablePlantPlateProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :plant_plates, :projects do |t|
      t.index [:plant_plate_id, :project_id]
    end
  end
end
