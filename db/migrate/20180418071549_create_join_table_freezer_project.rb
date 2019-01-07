# frozen_string_literal: true

class CreateJoinTableFreezerProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :freezers, :projects do |t|
      t.index %i[freezer_id project_id]
    end
  end
end
