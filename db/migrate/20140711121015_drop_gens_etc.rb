# frozen_string_literal: true

class DropGensEtc < ActiveRecord::Migration
  def change
    drop_table :gens
    drop_table :species_epithets
    drop_table :authors
  end
end
