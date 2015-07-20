class LabsProjects < ActiveRecord::Migration
  def change
    create_table :labs_projects, id: false do |t|
      t.integer :lab_id
      t.integer :project_id
    end
  end
end
