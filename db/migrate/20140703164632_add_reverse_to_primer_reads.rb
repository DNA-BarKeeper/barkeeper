class AddReverseToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :reverse, :boolean
  end
end
