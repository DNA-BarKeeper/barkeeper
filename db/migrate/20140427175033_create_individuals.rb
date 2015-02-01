class CreateIndividuals < ActiveRecord::Migration
  def change
    create_table :individuals do |t|
      t.string :specimen_id
      t.string :DNA_bank_id
      t.string :collector

      t.timestamps
    end
  end
end
