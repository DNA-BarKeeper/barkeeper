class CreateMislabelAnalyses < ActiveRecord::Migration[5.0]
  def change
    create_table :mislabel_analyses do |t|
      t.string :title

      t.timestamps
    end
  end
end
