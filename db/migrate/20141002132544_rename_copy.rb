# frozen_string_literal: true

class RenameCopy < ActiveRecord::Migration
  def change
    rename_column :marker_sequences, :copy_id, :isolate_id
  end
end
