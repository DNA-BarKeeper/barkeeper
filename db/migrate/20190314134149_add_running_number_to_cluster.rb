class AddRunningNumberToCluster < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :running_number, :integer
  end
end
