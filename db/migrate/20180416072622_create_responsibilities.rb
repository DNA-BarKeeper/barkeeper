# frozen_string_literal: true

class CreateResponsibilities < ActiveRecord::Migration[5.0]
  def change
    create_table :responsibilities do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
