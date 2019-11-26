class CreateNgsResults < ActiveRecord::Migration[5.0]
  def change
    create_table :ngs_results do |t|
      t.belongs_to :isolate, index: true
      t.belongs_to :marker, index: true
      t.belongs_to :ngs_run, index: true

      t.integer :hq_sequences
      t.integer :incomplete_sequences
      t.integer :cluster_count

      t.timestamps
    end
  end
end
