# frozen_string_literal: true

class CreateTissues < ActiveRecord::Migration
  def change
    create_table :tissues do |t|
      t.string :name

      t.timestamps
    end
  end
end
