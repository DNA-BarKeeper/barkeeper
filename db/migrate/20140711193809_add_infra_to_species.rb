# frozen_string_literal: true

class AddInfraToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :infraspecific, :string
  end
end
