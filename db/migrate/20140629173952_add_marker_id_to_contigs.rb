class AddMarkerIdToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :marker_id, :integer
  end
end
