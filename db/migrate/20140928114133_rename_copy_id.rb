# frozen_string_literal: true

class RenameCopyId < ActiveRecord::Migration
  def change
    rename_column :contigs, :copy_id, :isolate_id
  end
end
