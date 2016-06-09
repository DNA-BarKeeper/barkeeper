class CreateSubdivisions < ActiveRecord::Migration
  def change
    create_table :subdivisions do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
