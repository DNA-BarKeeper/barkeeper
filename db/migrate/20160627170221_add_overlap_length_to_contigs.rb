class AddOverlapLengthToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :overlap_length, :integer, default: 15
    add_column :contigs, :allowed_mismatch_percent, :integer, default: 5
  end
end
