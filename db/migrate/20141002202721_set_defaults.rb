# frozen_string_literal: true

class SetDefaults < ActiveRecord::Migration
  def change
    change_column :primer_reads, :window_size, :integer, default: 10
    change_column :primer_reads, :count_in_window, :integer, default: 8
    change_column :primer_reads, :min_quality_score, :integer, default: 30
  end
end
