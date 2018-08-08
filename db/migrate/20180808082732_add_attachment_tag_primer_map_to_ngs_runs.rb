class AddAttachmentTagPrimerMapToNgsRuns < ActiveRecord::Migration[5.0]
  def self.up
    change_table :ngs_runs do |t|
      t.attachment :tag_primer_map
    end
  end

  def self.down
    remove_attachment :ngs_runs, :tag_primer_map
  end
end
