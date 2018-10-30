# frozen_string_literal: true

class CreateMicronicPlates < ActiveRecord::Migration
  def change
    create_table :micronic_plates do |t|
      t.string :micronic_plate_id
      t.string :name

      t.timestamps
    end
  end
end
