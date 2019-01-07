# frozen_string_literal: true

class AddCommentToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :comment, :text
  end
end
