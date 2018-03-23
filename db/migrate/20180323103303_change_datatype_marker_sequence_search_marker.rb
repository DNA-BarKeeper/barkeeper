class ChangeDatatypeMarkerSequenceSearchMarker < ActiveRecord::Migration[5.0]
  def up
    change_column :marker_sequence_searches, :marker, :string
  end

  def down
    change_column :marker_sequence_searches, :marker, :integer
  end
end
