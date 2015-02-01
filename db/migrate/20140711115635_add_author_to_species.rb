class AddAuthorToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :author, :string
  end
end
