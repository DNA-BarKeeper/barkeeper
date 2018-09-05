class CreateCentroidSequences < ActiveRecord::Migration[5.0]
  def change
    create_table :centroid_sequences do |t|

      t.timestamps
    end
  end
end
