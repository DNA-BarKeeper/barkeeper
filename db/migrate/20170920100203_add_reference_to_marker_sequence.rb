class AddReferenceToMarkerSequence < ActiveRecord::Migration[5.0]
  def up
    add_column :marker_sequences, :reference, :string
  end

  def down
    remove_column :marker_sequences, :reference, :string
  end
end
