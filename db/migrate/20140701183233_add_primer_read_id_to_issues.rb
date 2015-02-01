class AddPrimerReadIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :primer_read_id, :integer
  end
end
