# frozen_string_literal: true

class AddBaseCountToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :base_count, :integer
  end
end
