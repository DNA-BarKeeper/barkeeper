# frozen_string_literal: true

class RenameMarkerSeqId < ActiveRecord::Migration
  def change
    rename_column :contigs, :marker_seq_id, :marker_sequence_id
  end
end
