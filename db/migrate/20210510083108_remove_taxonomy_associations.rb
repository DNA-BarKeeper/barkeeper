class RemoveTaxonomyAssociations < ActiveRecord::Migration[5.2]
  def change
    remove_column :individuals, :species_id
    remove_column :ngs_runs, :higher_order_taxon_id

    drop_table :higher_order_taxa_markers

    drop_table :projects_species
    drop_table :families_projects
    drop_table :orders_projects
    drop_table :higher_order_taxa_projects
  end
end
