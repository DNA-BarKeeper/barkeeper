class RemoveSequenceFromMarkers < ActiveRecord::Migration
  def change
    remove_column :markers, :sequence, :text
  end
end
