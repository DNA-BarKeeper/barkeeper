class IndividualChangeTypeElevation < ActiveRecord::Migration[5.2]
  def change
    rename_column :individuals, :elevation, :elevation_orig
    add_column :individuals, :elevation, :decimal
  end
end
