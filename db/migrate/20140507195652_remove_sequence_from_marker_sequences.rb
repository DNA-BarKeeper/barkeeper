class RemoveSequenceFromMarkerSequences < ActiveRecord::Migration
  def change
    remove_column :marker_sequences, :sequence, :string
  end
end
