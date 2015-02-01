class RemoveAuthorFromSpecies < ActiveRecord::Migration
  def change
    remove_column :species, :author, :string
  end
end
