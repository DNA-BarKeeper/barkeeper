class RemoveUnusedIsolateColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :isolates, :comment_copy, :text
    remove_column :isolates, :comment_orig, :text

    remove_column :isolates, :concentration, :decimal
    remove_column :isolates, :concentration_orig, :decimal
    remove_column :isolates, :concentration_copy, :decimal

    remove_column :isolates, :lab_id_orig, :integer
    remove_column :isolates, :lab_id_copy, :integer

    remove_column :isolates, :micronic_plate_id, :integer
    remove_column :isolates, :micronic_plate_id_orig, :integer
    remove_column :isolates, :micronic_plate_id_copy, :integer

    remove_column :isolates, :micronic_tube_id, :string
    remove_column :isolates, :micronic_tube_id_orig, :string
    remove_column :isolates, :micronic_tube_id_copy, :string

    remove_column :isolates, :well_pos_micronic_plate, :string
    remove_column :isolates, :well_pos_micronic_plate_orig, :string
    remove_column :isolates, :well_pos_micronic_plate_copy, :string
  end
end
