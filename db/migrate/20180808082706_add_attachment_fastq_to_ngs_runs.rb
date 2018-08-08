class AddAttachmentFastqToNgsRuns < ActiveRecord::Migration[5.0]
  def self.up
    change_table :ngs_runs do |t|
      t.attachment :fastq
    end
  end

  def self.down
    remove_attachment :ngs_runs, :fastq
  end
end
