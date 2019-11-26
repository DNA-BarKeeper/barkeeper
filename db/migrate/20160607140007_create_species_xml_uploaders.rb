# frozen_string_literal: true

class CreateSpeciesXmlUploaders < ActiveRecord::Migration
  def change
    create_table :species_xml_uploaders do |t|
      t.timestamps null: false
    end
  end
end
