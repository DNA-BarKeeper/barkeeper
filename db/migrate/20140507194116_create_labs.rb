# frozen_string_literal: true

class CreateLabs < ActiveRecord::Migration
  def change
    create_table :labs do |t|
      t.string :labcode

      t.timestamps
    end
  end
end
