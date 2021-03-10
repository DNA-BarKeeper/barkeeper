class CreateTaxa < ActiveRecord::Migration[5.2]
  def change
    create_table :taxa do |t|
      t.string :scientific_name
      t.string :common_name
      t.string :position
      t.string :synonym
      t.string :author
      t.text :comment

      t.timestamps
    end
  end
end
