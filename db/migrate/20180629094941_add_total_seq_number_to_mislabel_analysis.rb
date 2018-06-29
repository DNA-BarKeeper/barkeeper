class AddTotalSeqNumberToMislabelAnalysis < ActiveRecord::Migration[5.0]
  def change
    add_column :mislabel_analyses, :total_seq_number, :integer
  end
end
