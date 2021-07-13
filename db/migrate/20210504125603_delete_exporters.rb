class DeleteExporters < ActiveRecord::Migration[5.2]
  def up
    drop_table :species_exporters
    drop_table :specimen_exporters
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
