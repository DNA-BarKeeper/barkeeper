# frozen_string_literal: true

class CreateJoinTableLabRackProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :lab_racks, :projects do |t|
      t.index %i[lab_rack_id project_id]
    end
  end
end
