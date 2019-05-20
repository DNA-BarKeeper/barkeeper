class RenameNgsRunsNameToComment < ActiveRecord::Migration[5.0]
  def change
    rename_column :ngs_runs, :name, :comment
    rename_column :ngs_runs, :tag_mismates, :tag_mismatches
  end
end
