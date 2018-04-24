class AddProjectToMarkerSequenceSearch < ActiveRecord::Migration[5.0]
  def change
    add_reference :marker_sequence_searches, :project, foreign_key: true
  end
end
