class AddNgsRunIdToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :ngs_run_id, :integer
  end
end
