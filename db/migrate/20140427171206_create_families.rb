# frozen_string_literal: true

class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.string :name
      t.string :author

      t.timestamps
    end
  end
end
