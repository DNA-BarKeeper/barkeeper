class AdjustContigSearchToTaxonModel < ActiveRecord::Migration[5.2]
  def change
    rename_column :contig_searches, :species, :taxon
    remove_column :contig_searches, :family
    remove_column :contig_searches, :order
  end
end
