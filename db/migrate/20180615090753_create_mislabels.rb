# frozen_string_literal: true

class CreateMislabels < ActiveRecord::Migration[5.0]
  def change
    create_table :mislabels do |t|
      t.string :level
      t.decimal :confidence
      t.string :proposed_label
      t.string :proposed_path
      t.string :path_confidence
      t.belongs_to :mislabel_analysis, index: true

      t.timestamps
    end
  end
end
