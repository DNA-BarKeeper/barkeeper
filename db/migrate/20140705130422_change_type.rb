class ChangeType < ActiveRecord::Migration
  def change
    change_column(:primer_reads, :aligned_seq, :text)
  end
end
