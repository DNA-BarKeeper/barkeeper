class RemoveTagPrimerMapFromNgsRun < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :ngs_runs, :tag_primer_map
  end
end
