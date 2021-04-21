class AddDefaultsToNgsRunParameters < ActiveRecord::Migration[5.2]
  def change
    change_column :ngs_runs, :primer_mismatches, :decimal, default: 0.1
    change_column :ngs_runs, :quality_threshold, :integer, default: 25
    change_column :ngs_runs, :tag_mismatches, :integer, default: 2
  end
end
