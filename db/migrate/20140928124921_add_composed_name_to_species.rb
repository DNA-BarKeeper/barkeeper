class AddComposedNameToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :composed_name, :string
  end
end
