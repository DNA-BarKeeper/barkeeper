class RemoveFinishedCacheFromTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_column :taxa, :finished
    remove_column :taxa, :finished_count
  end
end
