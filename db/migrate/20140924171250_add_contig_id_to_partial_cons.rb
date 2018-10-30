# frozen_string_literal: true

class AddContigIdToPartialCons < ActiveRecord::Migration
  def change
    add_column :partial_cons, :contig_id, :integer
  end
end
