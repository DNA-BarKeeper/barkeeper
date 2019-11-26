# frozen_string_literal: true

class AddTmToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :tm, :string
  end
end
