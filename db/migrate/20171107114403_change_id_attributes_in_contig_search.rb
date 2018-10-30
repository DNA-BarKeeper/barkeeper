# frozen_string_literal: true

class ChangeIdAttributesInContigSearch < ActiveRecord::Migration[5.0]
  def up
    rename_column :contig_searches, :order_id, :order
    rename_column :contig_searches, :marker_id, :marker

    change_column :contig_searches, :order, :string
    change_column :contig_searches, :marker, :string
  end

  def down
    rename_column :contig_searches, :order, :order_id
    rename_column :contig_searches, :marker, :marker_id

    change_column :contig_searches, :order_id, :integer
    change_column :contig_searches, :marker_id, :integer
  end
end
