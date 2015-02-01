class ChangeSpeciesIdNames < ActiveRecord::Migration
  def change

      rename_column :species, :epithet_id, :species_epithet_id
      rename_column :species, :genus_id, :gen_id

  end
end
