# frozen_string_literal: true

class AddAttributesToMislabelAnalysis < ActiveRecord::Migration[5.0]
  def change
    add_column :mislabel_analyses, :automatic, :boolean, default: false
    add_reference :mislabel_analyses, :marker, foreign_key: true
  end
end
