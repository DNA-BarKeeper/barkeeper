# frozen_string_literal: true

class RenameHigher < ActiveRecord::Migration
  def change
    rename_table :higher_order_taxons, :higher_order_taxa
  end
end
