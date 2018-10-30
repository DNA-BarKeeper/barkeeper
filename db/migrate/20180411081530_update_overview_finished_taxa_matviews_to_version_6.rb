# frozen_string_literal: true

class UpdateOverviewFinishedTaxaMatviewsToVersion6 < ActiveRecord::Migration[5.0]
  def change
    update_view :overview_finished_taxa_matviews,
                version: 6,
                revert_to_version: 5,
                materialized: true
  end
end
