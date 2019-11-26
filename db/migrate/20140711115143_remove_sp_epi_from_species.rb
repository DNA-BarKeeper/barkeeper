# frozen_string_literal: true

class RemoveSpEpiFromSpecies < ActiveRecord::Migration
  def change
    remove_column :species, :species_epithet_id, :integer
  end
end
