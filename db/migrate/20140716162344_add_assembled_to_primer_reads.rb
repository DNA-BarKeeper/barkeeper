# frozen_string_literal: true

class AddAssembledToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :assembled, :boolean
  end
end
