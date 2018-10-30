# frozen_string_literal: true

class AddLocationInRackToMicronicPlate < ActiveRecord::Migration
  def change
    add_column :micronic_plates, :location_in_rack, :string
  end
end
