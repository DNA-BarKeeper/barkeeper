class CreateHigherOrderTaxaMarkersJoinTable < ActiveRecord::Migration
  def change
    create_table :higher_order_taxa_markers, id: false do |t|
      t.integer :higher_order_taxon_id
      t.integer :marker_id
    end
  end
end
