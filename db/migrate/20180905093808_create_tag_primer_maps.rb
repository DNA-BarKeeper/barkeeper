class CreateTagPrimerMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :tag_primer_maps do |t|

      t.timestamps
    end
  end
end
