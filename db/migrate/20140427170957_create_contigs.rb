# frozen_string_literal: true

class CreateContigs < ActiveRecord::Migration
  def change
    create_table :contigs do |t|
      t.string :name
      t.text :consensus

      t.timestamps
    end
  end
end
