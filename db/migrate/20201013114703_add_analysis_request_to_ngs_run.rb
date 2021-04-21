class AddAnalysisRequestToNgsRun < ActiveRecord::Migration[5.2]
  def change
    add_column :ngs_runs, :analysis_requested, :boolean, :default => false
    add_column :ngs_runs, :analysis_started, :boolean, :default => false
  end
end
