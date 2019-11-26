# frozen_string_literal: true

class AddGermanToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :german_name, :string
  end
end
