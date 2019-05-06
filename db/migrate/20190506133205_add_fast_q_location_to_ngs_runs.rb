class AddFastQLocationToNgsRuns < ActiveRecord::Migration[5.0]
  def change
    add_column :ngs_runs, :fastq_location, :string
  end
end
