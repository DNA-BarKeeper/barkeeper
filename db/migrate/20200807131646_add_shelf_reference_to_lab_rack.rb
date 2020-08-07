class AddShelfReferenceToLabRack < ActiveRecord::Migration[5.2]
  def change
    rename_column :lab_racks, :shelf, :shelf_name

    add_reference :lab_racks, :shelf, foreign_key: true
    remove_reference :lab_racks, :freezer
  end
end
