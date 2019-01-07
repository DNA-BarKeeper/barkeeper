# frozen_string_literal: true

class CreateContigPdeUploader < ActiveRecord::Migration[5.0]
  def change
    create_table :contig_pde_uploaders do |t|
      t.attachment :uploaded_file
      t.timestamps
    end
  end
end
