class AddAttachmentTagPrimerMapToTagPrimerMaps < ActiveRecord::Migration[5.0]
  def self.up
    change_table :tag_primer_maps do |t|
      t.attachment :tag_primer_map
    end
  end

  def self.down
    remove_attachment :tag_primer_maps, :tag_primer_map
  end
end
