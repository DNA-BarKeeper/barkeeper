# frozen_string_literal: true

class UpdateOverviewFinishedTaxaMatviewsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    update_view :overview_finished_taxa_matviews,
                version: 3,
                revert_to_version: 2,
                materialized: true
  end
end
