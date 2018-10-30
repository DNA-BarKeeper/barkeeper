# frozen_string_literal: true

class AddVerifiedByToContigSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :contig_searches, :verified_by, :string
  end
end
