class ChangeHasSpeciesOfIndividualSearch < ActiveRecord::Migration[5.0]
  def change
    change_column :individual_searches, :has_species, 'integer USING CAST(has_issue AS integer)'
  end
end
