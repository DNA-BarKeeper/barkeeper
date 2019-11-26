# frozen_string_literal: true

class AddAltNameToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :alt_name, :string
  end
end
