# frozen_string_literal: true

class AddGenusNameToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :genus_name, :string
  end
end
