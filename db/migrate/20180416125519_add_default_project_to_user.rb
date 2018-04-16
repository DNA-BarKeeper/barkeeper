class AddDefaultProjectToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :default_project_id, :integer
  end
end
