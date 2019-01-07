# frozen_string_literal: true

class AddGbolToMarkers < ActiveRecord::Migration
  def change
    add_column :markers, :is_gbol, :boolean
  end
end
