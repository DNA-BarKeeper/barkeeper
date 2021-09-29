class DropResponsibilityTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :responsibilities
    drop_table :responsibilities_users
  end
end
