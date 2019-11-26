# frozen_string_literal: true

class CreateLabRacks < ActiveRecord::Migration
  def change
    create_table :lab_racks do |t|
      t.string :rackcode

      t.timestamps
    end
  end
end
