class AddDescendantCounterToTaxon < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :descendants_count, :integer
  end
end
