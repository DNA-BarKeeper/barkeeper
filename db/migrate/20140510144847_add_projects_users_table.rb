# frozen_string_literal: true

class AddProjectsUsersTable < ActiveRecord::Migration
  def change
    create_table :projects_users, id: false do |t|
      t.references :project
      t.references :user
    end
  end
end
