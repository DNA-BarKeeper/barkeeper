class AddRackPositionToLabRacks < ActiveRecord::Migration
  def change
    add_column :lab_racks, :rack_position, :string
  end
end
