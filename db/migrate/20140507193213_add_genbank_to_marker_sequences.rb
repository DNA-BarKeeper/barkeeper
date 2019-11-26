# frozen_string_literal: true

class AddGenbankToMarkerSequences < ActiveRecord::Migration
  def change
    add_column :marker_sequences, :genbank, :string
  end
end
