class CreateHigherOrderTaxons < ActiveRecord::Migration
  def change
    create_table :higher_order_taxons do |t|
      t.string :name

      t.timestamps
    end
  end
end
