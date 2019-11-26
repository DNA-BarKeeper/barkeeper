# frozen_string_literal: true

class AddVerifiedByToMarkerSequenceSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :marker_sequence_searches, :verified_by, :string
  end
end
