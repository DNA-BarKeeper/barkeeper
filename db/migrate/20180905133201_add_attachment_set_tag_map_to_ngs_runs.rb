class AddAttachmentSetTagMapToNgsRuns < ActiveRecord::Migration[5.0]
  def self.up
    change_table :ngs_runs do |t|
      t.attachment :set_tag_map
    end
  end

  def self.down
    remove_attachment :ngs_runs, :set_tag_map
  end
end
