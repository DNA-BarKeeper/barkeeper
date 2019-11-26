class CreateJoinTableNgsRunProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :ngs_runs, :projects do |t|
      t.index [:ngs_run_id, :project_id]
    end
  end
end
