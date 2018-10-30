# frozen_string_literal: true

class AddChromatogramToPrimerRead < ActiveRecord::Migration
  def self.up
    add_attachment :primer_reads, :chromatogram
  end

  def self.down
    remove_attachment :primer_reads, :chromatogram
  end
end
