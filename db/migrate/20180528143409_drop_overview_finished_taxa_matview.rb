class DropOverviewFinishedTaxaMatview < ActiveRecord::Migration[5.0]
  def change
    drop_view :overview_finished_taxa_matviews, materialized: true
  end
end
