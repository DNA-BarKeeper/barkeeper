class AddLabRackIdToMicronicPlates < ActiveRecord::Migration
  def change
    add_column :micronic_plates, :lab_rack_id, :integer
  end
end
