class AddTaxonToNgsRuns < ActiveRecord::Migration[5.2]
  def change
    add_reference :ngs_runs, :taxon
    add_foreign_key :ngs_runs, :taxa
  end
end
