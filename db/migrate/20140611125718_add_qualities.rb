# frozen_string_literal: true

class AddQualities < ActiveRecord::Migration
  def change
    add_column :primer_reads, :qualities, :integer, array: true
  end
end
