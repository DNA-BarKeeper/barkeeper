# frozen_string_literal: true

class AddAlignedPeakIndicesToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :aligned_peak_indices, :integer, array: true
  end
end
