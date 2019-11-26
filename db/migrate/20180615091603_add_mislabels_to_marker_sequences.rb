# frozen_string_literal: true

class AddMislabelsToMarkerSequences < ActiveRecord::Migration[5.0]
  def change
    add_reference :mislabels, :marker_sequence, foreign_key: true
  end
end
