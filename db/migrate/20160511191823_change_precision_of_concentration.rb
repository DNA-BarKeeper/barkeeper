class ChangePrecisionOfConcentration < ActiveRecord::Migration
  def change
    change_column :isolates, :concentration_orig, :decimal, :precision => 15, :scale => 2
    change_column :isolates, :concentration_copy, :decimal, :precision => 15, :scale => 2
  end
end
