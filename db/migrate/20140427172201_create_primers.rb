class CreatePrimers < ActiveRecord::Migration
  def change
    create_table :primers do |t|
      t.string :name
      t.string :sequence
      t.boolean :reverse

      t.timestamps
    end
  end
end
