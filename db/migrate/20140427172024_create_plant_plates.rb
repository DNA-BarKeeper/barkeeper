# frozen_string_literal: true

class CreatePlantPlates < ActiveRecord::Migration
  def change
    create_table :plant_plates do |t|
      t.string :name
      t.integer :how_many

      t.timestamps
    end
  end
end
