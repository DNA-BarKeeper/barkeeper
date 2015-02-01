class AddPartialCons2ToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :partial_cons2, :text
  end
end
