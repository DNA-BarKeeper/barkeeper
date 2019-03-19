class CreateBlastHits < ActiveRecord::Migration[5.0]
  def change
    create_table :blast_hits do |t|
      t.belongs_to :cluster, index: true
      t.string :taxonomy
      t.decimal :e_value

      t.timestamps
    end
  end
end
