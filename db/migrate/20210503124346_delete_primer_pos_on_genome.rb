class DeletePrimerPosOnGenome < ActiveRecord::Migration[5.2]
  def up
    drop_table :primer_pos_on_genomes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
