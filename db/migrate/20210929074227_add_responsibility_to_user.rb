class AddResponsibilityToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :responsibility, :integer
  end
end
