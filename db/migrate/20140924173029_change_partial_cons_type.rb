# frozen_string_literal: true

class ChangePartialConsType < ActiveRecord::Migration
  def change
    change_column :partial_cons, :aligned_sequence, :text
    change_column :partial_cons, :sequence, :text
  end
end
