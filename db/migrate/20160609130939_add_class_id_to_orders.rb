class AddClassIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :taxonomic_class_id, :integer
  end
end
