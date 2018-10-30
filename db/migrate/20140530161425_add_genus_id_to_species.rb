# frozen_string_literal: true

class AddGenusIdToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :genus_id, :integer
  end
end
