# frozen_string_literal: true

class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :author
      t.string :genus_name
      t.string :species_epithet

      t.timestamps
    end
  end
end
