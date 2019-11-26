class RemoveColumnIsCopyFromIsolates < ActiveRecord::Migration[5.0]
  def change
    remove_column :isolates, :isCopy
  end
end
