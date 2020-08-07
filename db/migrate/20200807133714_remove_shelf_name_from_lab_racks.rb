class RemoveShelfNameFromLabRacks < ActiveRecord::Migration[5.2]
  def change
    remove_column :lab_racks, :shelf_name, :string
  end
end
