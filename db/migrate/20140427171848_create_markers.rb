class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.string :name
      t.text :sequence
      t.string :accession

      t.timestamps
    end
  end
end
