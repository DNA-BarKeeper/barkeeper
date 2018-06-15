class CreateMislabels < ActiveRecord::Migration[5.0]
  def change
    create_table :mislabels do |t|
      t.string :level
      t.decimal :confidence
      t.string :proposed_label
      t.string :proposed_path
      t.string :path_confidence
      t.references :mislabel_analyses, foreign_key: true

      t.timestamps
    end
  end
end
