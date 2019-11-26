# frozen_string_literal: true

class CreateJoinTableMicronicPlateProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :micronic_plates, :projects do |t|
      t.index %i[micronic_plate_id project_id], name: 'index_micronic_plates_projects'
    end
  end
end
