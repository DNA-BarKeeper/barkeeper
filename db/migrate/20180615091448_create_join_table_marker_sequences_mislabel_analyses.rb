# frozen_string_literal: true

class CreateJoinTableMarkerSequencesMislabelAnalyses < ActiveRecord::Migration[5.0]
  def change
    create_join_table :marker_sequences, :mislabel_analyses do |t|
      t.index %i[marker_sequence_id mislabel_analysis_id], name: 'index_marker_sequences_mislabel_analyses'
    end
  end
end
