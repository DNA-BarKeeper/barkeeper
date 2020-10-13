class RemoveDefaultFromNgsRunPrimerMismatches < ActiveRecord::Migration[5.2]
  def change
    change_column :ngs_runs, :primer_mismatches, :decimal
  end
end
