class PrimerReadsProjects < ActiveRecord::Migration
  def change
    create_table :primer_reads_projects, id: false do |t|
      t.integer :primer_read_id
      t.integer :project_id
    end
  end
end
