class UpdateOverviewAllTaxaMatviewsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    update_view :overview_all_taxa_matviews, version: 2, revert_to_version: 1, materialized: true
  end
end
