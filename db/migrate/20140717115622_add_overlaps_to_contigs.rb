class AddOverlapsToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :overlaps, :integer
  end
end
