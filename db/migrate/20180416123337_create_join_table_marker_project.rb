# frozen_string_literal: true

class CreateJoinTableMarkerProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :markers, :projects do |t|
      t.index %i[marker_id project_id]
    end
  end
end
