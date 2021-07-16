class DropTaxonomicTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :divisions, force: :cascade
    drop_table :families, force: :cascade
    drop_table :higher_order_taxa, force: :cascade
    drop_table :orders, force: :cascade
    drop_table :species, force: :cascade
    drop_table :subdivisions, force: :cascade
    drop_table :taxonomic_classes, force: :cascade
  end
end
