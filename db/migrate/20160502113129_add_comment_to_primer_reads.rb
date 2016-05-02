class AddCommentToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :comment, :string
  end
end
