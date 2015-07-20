class FamiliesProjects < ActiveRecord::Migration
  def change
    create_table :families_projects, id: false do |t|
      t.integer :family_id
      t.integer :project_id
    end
  end
end
