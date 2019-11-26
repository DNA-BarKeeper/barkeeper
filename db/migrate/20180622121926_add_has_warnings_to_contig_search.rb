# frozen_string_literal: true

class AddHasWarningsToContigSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :contig_searches, :has_warnings, :integer
  end
end
