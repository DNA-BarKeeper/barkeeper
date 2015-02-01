class AddExpectedReadsToMarkers < ActiveRecord::Migration
  def change
    add_column :markers, :expected_reads, :integer
  end
end
