class AddAttributesToMarkerSequenceSearch < ActiveRecord::Migration[5.0]
  def up
    add_column :marker_sequence_searches, :user_id, :integer
    add_column :marker_sequence_searches, :title, :string
    add_column :marker_sequence_searches, :family, :string
    add_column :marker_sequence_searches, :marker, :integer
    add_column :marker_sequence_searches, :min_length, :integer
    add_column :marker_sequence_searches, :max_length, :integer
  end

  def down
    remove_column :marker_sequence_searches, :user_id, :integer
    remove_column :marker_sequence_searches, :title, :string
    remove_column :marker_sequence_searches, :family, :string
    remove_column :marker_sequence_searches, :marker, :integer
    remove_column :marker_sequence_searches, :min_length, :integer
    remove_column :marker_sequence_searches, :max_length, :integer
  end
end
