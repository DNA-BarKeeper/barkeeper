class AddUserToIsolates < ActiveRecord::Migration
  def change
    add_column :isolates, :user_id, :integer
  end
end
