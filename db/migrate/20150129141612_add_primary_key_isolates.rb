class AddPrimaryKeyIsolates < ActiveRecord::Migration
  def change
    execute "ALTER TABLE isolates ADD PRIMARY KEY (id);"
  end
end
