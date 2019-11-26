class AddMarkerSequenceSearchToMislabelAnalysis < ActiveRecord::Migration[5.0]
  def change
    add_reference :marker_sequence_searches, :mislabel_analysis, foreign_key: true
  end
end
