# frozen_string_literal: true

class CreateIndividualSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :individual_searches do |t|
      t.string :title

      t.boolean :has_species
      t.boolean :has_problematic_location
      t.boolean :has_issue

      t.string :specimen_id
      t.string :DNA_bank_id
      t.string :species
      t.string :family
      t.string :order

      t.timestamps
    end
  end
end
