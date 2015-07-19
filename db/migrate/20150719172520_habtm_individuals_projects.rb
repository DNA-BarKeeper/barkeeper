class HabtmIndividualsProjects < ActiveRecord::Migration
  def change
    create_table :individuals_projects, id: false do |t|
      t.integer :individual_id
      t.integer :project_id
    end
  end
end