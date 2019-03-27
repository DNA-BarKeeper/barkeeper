class AddSequencesShortToNgsRun < ActiveRecord::Migration[5.0]
  def change
    add_column :ngs_runs, :sequences_short, :integer
  end
end
