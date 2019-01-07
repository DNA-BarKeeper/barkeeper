# frozen_string_literal: true

class RemoveAuthorIdFromSpecies < ActiveRecord::Migration
  def change
    remove_column :species, :author_id, :integer
  end
end
