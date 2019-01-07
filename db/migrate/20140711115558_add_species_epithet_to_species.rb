# frozen_string_literal: true

class AddSpeciesEpithetToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :species_epithet, :string
  end
end
