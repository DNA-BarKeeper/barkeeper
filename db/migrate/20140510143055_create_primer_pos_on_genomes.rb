# frozen_string_literal: true

class CreatePrimerPosOnGenomes < ActiveRecord::Migration
  def change
    create_table :primer_pos_on_genomes do |t|
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
