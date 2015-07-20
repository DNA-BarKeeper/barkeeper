class AddProjectsSpecies < ActiveRecord::Migration
  def change
    create_table :projects_species, id: false do |t|
      t.integer :project_id
      t.integer :species_id
    end
  end
end
