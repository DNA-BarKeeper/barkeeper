# frozen_string_literal: true

class CreateXmlUploaders < ActiveRecord::Migration
  def change
    create_table :xml_uploaders do |t|
      t.attachment :uploaded_file
      t.timestamps
    end
  end
end
