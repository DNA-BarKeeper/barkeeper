# frozen_string_literal: true

class CreateMarkerSequenceSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :marker_sequence_searches do |t|
      t.string :name
      t.string :verified
      t.string :species
      t.string :order
      t.string :specimen

      t.timestamps
    end
  end
end
