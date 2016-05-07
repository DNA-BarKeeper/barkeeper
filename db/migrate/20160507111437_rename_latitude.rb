class RenameLatitude < ActiveRecord::Migration
  def change
    rename_column :individuals, :latitude, :latitude_original
    rename_column :individuals, :longitude, :longitude_original
  end
end
