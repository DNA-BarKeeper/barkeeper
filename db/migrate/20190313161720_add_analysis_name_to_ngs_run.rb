class AddAnalysisNameToNgsRun < ActiveRecord::Migration[5.0]
  def change
    add_column :ngs_runs, :analysis_name, :string
  end
end
