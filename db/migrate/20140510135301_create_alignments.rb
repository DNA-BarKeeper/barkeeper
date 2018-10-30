# frozen_string_literal: true

class CreateAlignments < ActiveRecord::Migration
  def change
    create_table :alignments do |t|
      t.string :name
      t.string :URL

      t.timestamps
    end
  end
end
