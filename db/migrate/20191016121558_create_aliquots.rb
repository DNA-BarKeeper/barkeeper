class CreateAliquots < ActiveRecord::Migration[5.0]
  def change
    create_table :aliquots do |t|
      t.text :comment
      t.decimal :concentration
      t.string :well_pos_micronic_plate

      t.belongs_to :lab
      t.belongs_to :micronic_plate
      t.belongs_to :isolate

      t.timestamps
    end
  end
end
