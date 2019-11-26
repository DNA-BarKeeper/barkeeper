# frozen_string_literal: true

class AddCommentToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :comment, :string
  end
end
