class UpdateOverviewFinishedTaxaMatviewsToVersion5 < ActiveRecord::Migration[5.0]
  def change
    update_view :overview_finished_taxa_matviews,
      version: 5,
      revert_to_version: 4,
      materialized: true
  end
end
