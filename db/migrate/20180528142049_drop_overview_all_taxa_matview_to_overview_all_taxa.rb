# frozen_string_literal: true

class DropOverviewAllTaxaMatviewToOverviewAllTaxa < ActiveRecord::Migration[5.0]
  def change
    drop_view :overview_all_taxa_matviews, materialized: true
  end
end
