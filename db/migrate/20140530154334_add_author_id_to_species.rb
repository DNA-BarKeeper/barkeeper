class AddAuthorIdToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :author_id, :integer
  end
end
