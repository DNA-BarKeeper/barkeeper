class AddResultsToNgsRuns < ActiveRecord::Migration[5.0]
  def change
    add_attachment :ngs_runs, :results
  end
end
