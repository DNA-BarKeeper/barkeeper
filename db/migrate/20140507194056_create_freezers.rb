# frozen_string_literal: true

class CreateFreezers < ActiveRecord::Migration
  def change
    create_table :freezers do |t|
      t.string :freezercode

      t.timestamps
    end
  end
end
