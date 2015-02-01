class AddPos < ActiveRecord::Migration
  def change
    add_column :higher_order_taxa, :position, :integer
  end
end
