# frozen_string_literal: true

class AddAssemblyTriedToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :assembly_tried, :boolean
  end
end
