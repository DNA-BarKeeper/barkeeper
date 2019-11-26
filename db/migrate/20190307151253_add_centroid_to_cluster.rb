class AddCentroidToCluster < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :centroid_sequence, :string
  end
end
