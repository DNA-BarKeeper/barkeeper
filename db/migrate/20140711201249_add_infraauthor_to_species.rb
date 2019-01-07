# frozen_string_literal: true

class AddInfraauthorToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :author_infra, :string
  end
end
