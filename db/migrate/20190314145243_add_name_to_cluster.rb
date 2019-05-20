class AddNameToCluster < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :name, :string
  end
end
