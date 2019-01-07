# frozen_string_literal: true

class AddAltNameToMarkers < ActiveRecord::Migration
  def change
    add_column :markers, :alt_name, :string
  end
end
