class CreateJoinTableClustersProjects < ActiveRecord::Migration[5.0]
  def change
    create_join_table :clusters, :projects do |t|
      t.index [:cluster_id, :project_id]
    end
  end
end
