# frozen_string_literal: true

class AddReverseToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :reverse, :boolean
  end
end
