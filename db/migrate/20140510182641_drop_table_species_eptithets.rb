# frozen_string_literal: true

class DropTableSpeciesEptithets < ActiveRecord::Migration
  def change
    drop_table :species_eptithets
  end
end
