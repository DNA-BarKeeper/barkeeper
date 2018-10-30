# frozen_string_literal: true

class CreateJoinTableMarkerSequenceProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :marker_sequences, :projects do |t|
      t.index %i[marker_sequence_id project_id], name: 'index_marker_sequences_projects'
    end
  end
end
