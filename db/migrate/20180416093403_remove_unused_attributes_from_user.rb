class RemoveUnusedAttributesFromUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :admin
    remove_column :users, :guest
    remove_column :users, :supervisor
  end
end
