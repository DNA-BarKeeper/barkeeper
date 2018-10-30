# frozen_string_literal: true

class AddAlignedQualitiesToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :aligned_qualities, :integer, array: true
  end
end
