# frozen_string_literal: true

class AddFamilyIdToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :family_id, :integer
  end
end
