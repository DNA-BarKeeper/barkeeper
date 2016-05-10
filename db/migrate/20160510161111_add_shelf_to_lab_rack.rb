class AddShelfToLabRack < ActiveRecord::Migration
  def change
    add_column :lab_racks, :shelf, :string
  end
end
