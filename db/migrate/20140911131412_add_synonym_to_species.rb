class AddSynonymToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :synonym, :string
  end
end
