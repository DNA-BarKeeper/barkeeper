# frozen_string_literal: true

class AddLabcodeToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :labcode, :string
  end
end
