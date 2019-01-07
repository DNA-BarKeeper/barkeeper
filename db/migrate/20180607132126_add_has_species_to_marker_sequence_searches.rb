# frozen_string_literal: true

class AddHasSpeciesToMarkerSequenceSearches < ActiveRecord::Migration[5.0]
  def change
    add_column :marker_sequence_searches, :has_species, :boolean
  end
end
