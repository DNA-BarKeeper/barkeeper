class AddNoIsolateToMarkerSequenceSearches < ActiveRecord::Migration[5.0]
  def change
    add_column :marker_sequence_searches, :no_isolate, :boolean
  end
end
