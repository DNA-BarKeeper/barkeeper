class DropIssuesProjectsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :issues_projects
  end
end
