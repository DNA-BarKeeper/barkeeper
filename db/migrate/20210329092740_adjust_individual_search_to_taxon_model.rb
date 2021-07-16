class AdjustIndividualSearchToTaxonModel < ActiveRecord::Migration[5.2]
  def change
    remove_column :individual_searches, :family
    remove_column :individual_searches, :order
    rename_column :individual_searches, :has_species, :has_taxon
    rename_column :individual_searches, :species, :taxon
  end
end
