class CreateMarkerSequences < ActiveRecord::Migration
  def change
    create_table :marker_sequences do |t|
      t.string :name
      t.string :sequence

      t.timestamps
    end
  end
end
