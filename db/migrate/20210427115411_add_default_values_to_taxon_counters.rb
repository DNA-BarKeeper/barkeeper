class AddDefaultValuesToTaxonCounters < ActiveRecord::Migration[5.2]
  def change
    change_column :taxa, :children_count, :integer, :default => 0
    change_column :taxa, :descendants_count, :integer, :default => 0
  end
end
