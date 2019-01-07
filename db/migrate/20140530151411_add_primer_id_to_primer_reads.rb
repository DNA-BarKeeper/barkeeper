# frozen_string_literal: true

class AddPrimerIdToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :primer_id, :integer
  end
end
