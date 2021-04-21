class ChangeDefaultForPrimerMismatches < ActiveRecord::Migration[5.2]
  def change
    change_column :ngs_runs, :primer_mismatches, :decimal, default: 0.0
  end
end
