# frozen_string_literal: true

class CreatePartialCons < ActiveRecord::Migration
  def change
    create_table :partial_cons do |t|
      t.string :sequence
      t.string :aligned_sequence

      t.timestamps
    end
  end
end
