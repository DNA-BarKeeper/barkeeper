# frozen_string_literal: true

class CreateTaxonomicClasses < ActiveRecord::Migration
  def change
    create_table :taxonomic_classes do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
