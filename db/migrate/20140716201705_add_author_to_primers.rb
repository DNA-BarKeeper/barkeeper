# frozen_string_literal: true

class AddAuthorToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :author, :string
  end
end
