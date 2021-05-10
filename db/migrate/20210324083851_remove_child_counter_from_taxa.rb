class RemoveChildCounterFromTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_column :taxa, :child_counter, :integer
  end
end
