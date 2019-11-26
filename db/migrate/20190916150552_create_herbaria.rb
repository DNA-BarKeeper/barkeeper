class CreateHerbaria < ActiveRecord::Migration[5.0]
  def change
    create_table :herbaria do |t|
      t.string :name
      t.string :acronym

      t.timestamps
    end
  end
end
