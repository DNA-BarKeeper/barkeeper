# frozen_string_literal: true

class IsolatesProjects < ActiveRecord::Migration
  def change
    create_table :isolates_projects, id: false do |t|
      t.integer :isolate_id
      t.integer :project_id
    end
  end
end
