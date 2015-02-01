class AddGbolToMarkers < ActiveRecord::Migration
  def change
    add_column :markers, :is_gbol, :boolean
  end
end
