# frozen_string_literal: true

class AddMarkerIdToPrimer < ActiveRecord::Migration
  def change
    add_column :primers, :marker_id, :integer
    add_column :individuals, :species_id, :integer
    add_column :lab_racks, :freezer_id, :integer
    add_column :freezers, :lab_id, :integer
    add_column :copies, :tissue_id, :integer
    add_column :copies, :micronic_plate_id, :integer
    add_column :copies, :plant_plate_id, :integer
    add_column :primer_reads, :contig_id, :integer
    add_column :marker_sequences, :copy_id, :integer
    add_column :contigs, :marker_seq_id, :integer
  end
end
