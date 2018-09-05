class AddNgsRunToTagPrimerMap < ActiveRecord::Migration[5.0]
  def change
    add_reference :tag_primer_maps, :ngs_run, index: true
  end
end
