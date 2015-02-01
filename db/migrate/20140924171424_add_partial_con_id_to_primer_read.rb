class AddPartialConIdToPrimerRead < ActiveRecord::Migration
  def change
    add_column :primer_reads, :partial_con_id, :integer
  end
end
