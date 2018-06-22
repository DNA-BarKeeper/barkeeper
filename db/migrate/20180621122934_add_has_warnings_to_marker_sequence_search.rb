class AddHasWarningsToMarkerSequenceSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :marker_sequence_searches, :has_warnings, :integer
  end
end
