# frozen_string_literal: true

class AddTrimmedToPrimerRead < ActiveRecord::Migration
  def change
    add_column :primer_reads, :trimmedReadEnd, :integer
    add_column :primer_reads, :trimmedReadStart, :integer
  end
end
