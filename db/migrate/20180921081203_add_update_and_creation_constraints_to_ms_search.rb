class AddUpdateAndCreationConstraintsToMsSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :marker_sequence_searches, :min_age, :date
    add_column :marker_sequence_searches, :max_age, :date
    add_column :marker_sequence_searches, :min_update, :date
    add_column :marker_sequence_searches, :max_update, :date
  end
end
