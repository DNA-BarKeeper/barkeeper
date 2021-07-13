class AdjustMarkerSequenceSearchToTaxonModel < ActiveRecord::Migration[5.2]
  def change
    remove_column :marker_sequence_searches, :family
    remove_column :marker_sequence_searches, :order
    remove_column :marker_sequence_searches, :higher_order_taxon
    rename_column :marker_sequence_searches, :has_species, :has_taxon
    rename_column :marker_sequence_searches, :species, :taxon
  end
end
