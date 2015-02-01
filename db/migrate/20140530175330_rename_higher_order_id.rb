class RenameHigherOrderId < ActiveRecord::Migration
  def change
    rename_column :orders, :higher_order_id, :higher_order_taxon_id
  end
end
