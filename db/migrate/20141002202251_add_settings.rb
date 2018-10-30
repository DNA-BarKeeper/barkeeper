# frozen_string_literal: true

class AddSettings < ActiveRecord::Migration
  def change
    add_column :primer_reads, :window_size, :integer
    add_column :primer_reads, :count_in_window, :integer
    add_column :primer_reads, :min_quality_score, :integer
  end
end
