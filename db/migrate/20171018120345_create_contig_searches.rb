class CreateContigSearches < ActiveRecord::Migration[5.0]
  def up
    create_table :contig_searches do |t|
      t.string :species
      t.integer :order_id
      t.decimal :min_age
      t.decimal :max_age
      t.decimal :min_update
      t.decimal :max_update
      t.string :specimen
      t.string :family
      t.boolean :verified
      t.integer :marker_id
      t.string :name
      t.boolean :assembled

      t.timestamps
    end
  end

  def down
    drop_table :contig_searches
  end
end
