# frozen_string_literal: true

class AddDnabank < ActiveRecord::Migration
  def change
    add_column :isolates, :DNA_bank_id, :string
  end
end
