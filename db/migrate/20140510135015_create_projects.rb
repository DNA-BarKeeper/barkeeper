class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.datetime :start
      t.datetime :due

      t.timestamps
    end
  end
end
