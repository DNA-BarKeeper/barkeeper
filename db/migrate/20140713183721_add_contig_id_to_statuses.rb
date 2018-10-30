# frozen_string_literal: true

class AddContigIdToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :contig_id, :integer
  end
end
