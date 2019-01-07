# frozen_string_literal: true

class AddTitleToContigSearch < ActiveRecord::Migration[5.0]
  def up
    add_column :contig_searches, :title, :string
  end

  def down
    remove_column :contig_searches, :title
  end
end
