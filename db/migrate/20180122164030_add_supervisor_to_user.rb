# frozen_string_literal: true

class AddSupervisorToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :supervisor, :boolean
  end
end
