# frozen_string_literal: true

class CreateJoinTablePrimerProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :primers, :projects do |t|
      t.index %i[primer_id project_id]
    end
  end
end
