class AddAttributesToNgsRun < ActiveRecord::Migration[5.0]
  def change
    add_column :ngs_runs, :sequences_pre, :integer
    add_column :ngs_runs, :sequences_filtered, :integer
    add_column :ngs_runs, :sequences_high_qual, :integer
    add_column :ngs_runs, :sequences_one_primer, :integer

    rename_column :ngs_runs, :analysis_name, :name
  end
end
