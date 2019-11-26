# frozen_string_literal: true

class Pde < ActiveRecord::Migration
  def change
    add_column :contigs, :pde, :text
    add_column :contigs, :fas, :text
  end
end
