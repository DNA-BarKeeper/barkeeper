# frozen_string_literal: true

class OrdersProjects < ActiveRecord::Migration
  def change
    create_table :orders_projects, id: false do |t|
      t.integer :order_id
      t.integer :project_id
    end
  end
end
