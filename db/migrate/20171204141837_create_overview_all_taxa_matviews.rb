class CreateOverviewAllTaxaMatviews < ActiveRecord::Migration[5.0]
  def change
    create_view :overview_all_taxa_matviews, materialized: true
  end
end
