# frozen_string_literal: true

class AddPublishedToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :published, :date
  end
end
