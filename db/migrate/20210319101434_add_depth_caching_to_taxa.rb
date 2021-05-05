class AddDepthCachingToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :ancestry_depth, :integer, :default => 0
  end
end
