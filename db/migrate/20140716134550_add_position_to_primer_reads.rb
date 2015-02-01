class AddPositionToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :position, :integer
  end
end
