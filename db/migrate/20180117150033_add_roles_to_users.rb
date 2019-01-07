# frozen_string_literal: true

class AddRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :admin, :boolean
    add_column :users, :guest, :boolean
  end
end
