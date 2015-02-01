class AddUsedForConToPrimerRead < ActiveRecord::Migration
  def change
    add_column :primer_reads, :used_for_con, :boolean
  end
end
