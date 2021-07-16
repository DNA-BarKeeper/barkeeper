class AddTaxonomicRankToTaxon < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :taxonomic_rank, :integer
  end
end
