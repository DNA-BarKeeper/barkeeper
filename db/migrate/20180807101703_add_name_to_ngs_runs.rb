class AddNameToNgsRuns < ActiveRecord::Migration[5.0]
  def change
    add_column :ngs_runs, :name, :string
  end
end
