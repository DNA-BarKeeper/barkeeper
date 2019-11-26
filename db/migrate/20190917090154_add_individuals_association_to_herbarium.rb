class AddIndividualsAssociationToHerbarium < ActiveRecord::Migration[5.0]
  def change
    add_reference :individuals, :herbarium, foreign_key: true
  end
end
