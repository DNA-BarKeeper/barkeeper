class AddTotalSequencesToNgsResult < ActiveRecord::Migration[5.0]
  def change
    add_column :ngs_results, :total_sequences, :integer
  end
end
