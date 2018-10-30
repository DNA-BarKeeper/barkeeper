# frozen_string_literal: true

class AddPositionToSubdivisions < ActiveRecord::Migration
  def change
    add_column :subdivisions, :position, :integer
    add_column :subdivisions, :german_name, :string
    add_column :taxonomic_classes, :german_name, :string
  end
end
