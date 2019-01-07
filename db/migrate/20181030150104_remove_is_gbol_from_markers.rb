class RemoveIsGbolFromMarkers < ActiveRecord::Migration[5.0]
  def change
    remove_column :markers, :is_gbol, :string
  end
end
