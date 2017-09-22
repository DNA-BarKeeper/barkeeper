class ChangePrecisionOfLocationData < ActiveRecord::Migration[5.0]
  def up
    change_column :individuals, :latitude, :decimal, :precision => 15, :scale => 6
    change_column :individuals, :longitude, :decimal, :precision => 15, :scale => 6
  end

  def down
    change_column :individuals, :latitude, :decimal
    change_column :individuals, :longitude, :decimal
  end
end
