class AddTaxonToIndividuals < ActiveRecord::Migration[5.2]
  def change
    add_reference :individuals, :taxon
    add_foreign_key :individuals, :taxa
  end
end
