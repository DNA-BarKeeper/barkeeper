class DropTaxonomicTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :divisions
    drop_table :families
    drop_table :higher_order_taxa
    drop_table :orders
    drop_table :species
    drop_table :subdivisions
    drop_table :taxonomic_classes
  end
end
