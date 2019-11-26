# frozen_string_literal: true

class RenameCId < ActiveRecord::Migration
  def change
    rename_column :primer_reads, :copy_id, :isolate_id
  end
end
