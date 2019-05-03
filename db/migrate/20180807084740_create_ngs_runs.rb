class CreateNgsRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :ngs_runs do |t|
      t.integer :quality_threshold
      t.integer :tag_mismates
      t.integer :primer_mismatches

      t.timestamps
    end
  end
end
