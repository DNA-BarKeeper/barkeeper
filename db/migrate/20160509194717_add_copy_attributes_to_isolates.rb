class AddCopyAttributesToIsolates < ActiveRecord::Migration
  def change
    add_column :isolates, :lab_id_orig, :integer
    add_column :isolates, :lab_id_copy, :integer
    add_column :isolates, :isolation_date, :datetime
    add_column :isolates, :micronic_plate_id_orig, :integer
    add_column :isolates, :micronic_plate_id_copy, :integer
    add_column :isolates, :well_pos_micronic_plate_orig, :string
    add_column :isolates, :well_pos_micronic_plate_copy, :string
    add_column :isolates, :concentration_orig, :decimal
    add_column :isolates, :concentration_copy, :decimal
    add_column :isolates, :micronic_tube_id_orig, :string
    add_column :isolates, :micronic_tube_id_copy, :string
  end
end
