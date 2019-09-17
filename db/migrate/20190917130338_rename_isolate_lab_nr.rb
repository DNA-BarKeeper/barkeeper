class RenameIsolateLabNr < ActiveRecord::Migration[5.0]
  def change
    rename_column :isolates, :lab_nr, :lab_isolation_nr
  end
end
