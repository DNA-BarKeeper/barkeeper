# frozen_string_literal: true

class AddHigherOrderTaxonToMarkerSequenceSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :marker_sequence_searches, :higher_order_taxon, :string
  end
end
