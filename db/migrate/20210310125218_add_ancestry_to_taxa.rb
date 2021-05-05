class AddAncestryToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :ancestry, :string
    add_index :taxa, :ancestry
  end
end
