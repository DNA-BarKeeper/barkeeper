class AddGermaToHigherOrderTaxons < ActiveRecord::Migration
  def change
    add_column :higher_order_taxons, :german_name, :string
  end
end
