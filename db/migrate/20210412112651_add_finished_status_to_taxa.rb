class AddFinishedStatusToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :finished, :boolean, default: false
    add_column :taxa, :finished_count, :integer, default: 0
  end
end
