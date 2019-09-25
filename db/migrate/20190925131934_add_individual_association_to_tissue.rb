class AddIndividualAssociationToTissue < ActiveRecord::Migration[5.0]
  def change
    add_reference :individuals, :tissue, foreign_key: true
  end
end
