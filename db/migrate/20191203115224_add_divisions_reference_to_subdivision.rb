class AddDivisionsReferenceToSubdivision < ActiveRecord::Migration[5.0]
  def change
    add_reference :subdivisions, :division, foreign_key: true
  end
end
