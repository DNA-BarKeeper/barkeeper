class AddLatitudeToIndividuals < ActiveRecord::Migration
  def change
    add_column :individuals, :latitude, :decimal
    add_column :individuals, :longitude, :decimal
  end
end
