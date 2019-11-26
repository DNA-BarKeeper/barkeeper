# frozen_string_literal: true

class RemovePdeFromContigs < ActiveRecord::Migration[5.0]
  def up
    remove_column :contigs, :pde, :text
  end

  def down
    add_column :contigs, :pde, :text
  end
end
