class RemoveUnusedColumnsFromContigs < ActiveRecord::Migration[5.0]
  def change
    remove_column :contigs, :aligned_cons, :string
    remove_column :contigs, :overlaps, :integer
  end
end
