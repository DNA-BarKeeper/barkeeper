class AddSeqToMarkerSequences < ActiveRecord::Migration
  def change
    add_column :marker_sequences, :sequence, :text
  end
end
