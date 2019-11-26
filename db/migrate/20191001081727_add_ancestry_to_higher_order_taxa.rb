class AddAncestryToHigherOrderTaxa < ActiveRecord::Migration[5.0]
  def change
    add_column :higher_order_taxa, :ancestry, :string
    add_index :higher_order_taxa, :ancestry
  end
end
