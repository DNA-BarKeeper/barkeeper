# frozen_string_literal: true

class CreatePrimerReads < ActiveRecord::Migration
  def change
    create_table :primer_reads do |t|
      t.string :name
      t.text :sequence
      t.string :pherogram_url

      t.timestamps
    end
  end
end
