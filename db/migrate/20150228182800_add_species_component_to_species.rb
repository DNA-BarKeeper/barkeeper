# frozen_string_literal: true

class AddSpeciesComponentToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :species_component, :string
  end
end
