# frozen_string_literal: true

class RemovePartialConsTextColumnsFromContigs < ActiveRecord::Migration[5.0]
  def change
    remove_column :contigs, :partial_cons1, :text
    remove_column :contigs, :partial_cons2, :text
  end
end
