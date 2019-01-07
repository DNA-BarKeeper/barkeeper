# frozen_string_literal: true

class AddCopyIdToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :copy_id, :integer
  end
end
