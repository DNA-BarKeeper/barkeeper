class RemovePdeFromContigs < ActiveRecord::Migration[5.0]
  def up
    remove_column :contigs, :pde, :text
  end

  def down
    add_column :contigs_data, :pde, :text
  end
end
