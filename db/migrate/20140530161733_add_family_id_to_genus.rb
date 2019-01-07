# frozen_string_literal: true

class AddFamilyIdToGenus < ActiveRecord::Migration
  def change
    add_column :gens, :family_id, :integer
    add_column :families, :order_id, :integer
    add_column :orders, :higher_order_id, :integer
  end
end
