# frozen_string_literal: true

class AddPartialCons1ToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :partial_cons1, :text
  end
end
