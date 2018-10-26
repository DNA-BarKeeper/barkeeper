class AddDefaultForExpectedReadsToMarkers < ActiveRecord::Migration[5.0]
  def change
    change_column_default :markers, :expected_reads, from: nil, to: 1
  end
end
