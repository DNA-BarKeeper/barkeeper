# frozen_string_literal: true

class IssuesProjects < ActiveRecord::Migration
  def change
    create_table :issues_projects, id: false do |t|
      t.integer :issue_id
      t.integer :project_id
    end
  end
end
