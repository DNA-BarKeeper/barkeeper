# frozen_string_literal: true

class RemoveGenIdFromSpecies < ActiveRecord::Migration
  def change
    remove_column :species, :gen_id, :integer
  end
end
