class RemoveAttachmentFastqOfNgsRuns < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :ngs_runs, :fastq
  end
end
