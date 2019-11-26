# frozen_string_literal: true

class AddProcessedToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :processed, :boolean, default: false
  end
end
