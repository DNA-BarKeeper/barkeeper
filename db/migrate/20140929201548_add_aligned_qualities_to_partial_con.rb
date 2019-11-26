# frozen_string_literal: true

class AddAlignedQualitiesToPartialCon < ActiveRecord::Migration
  def change
    add_column :partial_cons, :aligned_qualities, :integer, array: true
  end
end
