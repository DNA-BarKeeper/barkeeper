class AddOverwrittenToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :overwritten, :boolean, :default => false
  end
end
