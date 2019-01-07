# frozen_string_literal: true

class AddPositionToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :position, :integer
  end
end
