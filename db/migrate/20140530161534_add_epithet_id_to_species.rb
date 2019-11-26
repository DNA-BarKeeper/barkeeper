# frozen_string_literal: true

class AddEpithetIdToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :epithet_id, :integer
  end
end
