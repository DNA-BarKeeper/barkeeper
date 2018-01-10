class CreateOverviewFinishedTaxaMatviews < ActiveRecord::Migration[5.0]
  def change
    create_view :overview_finished_taxa_matviews, materialized: true
  end
end
