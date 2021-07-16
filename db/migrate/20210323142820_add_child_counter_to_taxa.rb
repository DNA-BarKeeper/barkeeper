class AddChildCounterToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :child_counter, :integer, :default => 0
  end
end
