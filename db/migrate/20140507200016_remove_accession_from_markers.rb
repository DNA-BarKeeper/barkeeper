# frozen_string_literal: true

class RemoveAccessionFromMarkers < ActiveRecord::Migration
  def change
    remove_column :markers, :accession, :string
  end
end
