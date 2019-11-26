# frozen_string_literal: true

class ChangeTubeIdType < ActiveRecord::Migration
  def change
    change_column :isolates, :micronic_tube_id, :string
  end
end
