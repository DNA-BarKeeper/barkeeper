class AddDisplayNameColumnToIsolates < ActiveRecord::Migration[5.0]
  def change
    add_column :isolates, :display_name, :string
  end
end
