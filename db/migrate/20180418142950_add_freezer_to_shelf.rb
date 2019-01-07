# frozen_string_literal: true

class AddFreezerToShelf < ActiveRecord::Migration[5.0]
  def change
    add_reference :shelves, :freezer, foreign_key: true
  end
end
