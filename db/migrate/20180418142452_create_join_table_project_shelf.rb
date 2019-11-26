# frozen_string_literal: true

class CreateJoinTableProjectShelf < ActiveRecord::Migration[5.0]
  def change
    create_join_table :projects, :shelves do |t|
      t.index %i[project_id shelf_id]
    end
  end
end
