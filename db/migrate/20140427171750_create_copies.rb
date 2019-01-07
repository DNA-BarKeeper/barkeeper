# frozen_string_literal: true

class CreateCopies < ActiveRecord::Migration
  def change
    create_table :copies do |t|
      t.string :well_pos_plant_plate
      t.integer :lab_nr
      t.integer :micronic_tube_id
      t.string :well_pos_micronic_plate
      t.decimal :concentration

      t.timestamps
    end
  end
end
