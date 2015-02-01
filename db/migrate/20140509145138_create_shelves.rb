class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.string :name

      t.timestamps
    end
  end
end
