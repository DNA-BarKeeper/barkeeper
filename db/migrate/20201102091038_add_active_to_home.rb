class AddActiveToHome < ActiveRecord::Migration[5.2]
  def change
    add_column :homes, :active, :boolean
  end
end
