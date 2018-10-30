# frozen_string_literal: true

class AddVerifiedByToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :verified_by, :integer
    add_column :contigs, :verified_at, :datetime
  end
end
