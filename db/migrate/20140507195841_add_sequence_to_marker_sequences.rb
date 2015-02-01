class AddSequenceToMarkerSequences < ActiveRecord::Migration
  def change
    add_column :marker_sequences, :sequence, :string
  end
end
