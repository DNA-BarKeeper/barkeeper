class AddHigherOrderTaxonToNgsRun < ActiveRecord::Migration[5.0]
  def change
    add_reference :ngs_runs, :higher_order_taxon, foreign_key: true
  end
end
