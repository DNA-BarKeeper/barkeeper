# frozen_string_literal: true

class UpdateOverviewFinishedTaxaMatviewsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    update_view :overview_finished_taxa_matviews,
                version: 2,
                revert_to_version: 1,
                materialized: true
  end
end
