class AddReferencesToPrimerPosOnGenome < ActiveRecord::Migration[5.0]
  def change
    add_reference :primer_pos_on_genomes, :primer, foreign_key: true
    add_reference :primer_pos_on_genomes, :species, foreign_key: true
  end
end
