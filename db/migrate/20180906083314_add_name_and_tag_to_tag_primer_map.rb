class AddNameAndTagToTagPrimerMap < ActiveRecord::Migration[5.0]
  def change
    add_column :tag_primer_maps, :name, :string
    add_column :tag_primer_maps, :tag, :string
  end
end
