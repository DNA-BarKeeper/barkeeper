class AddDisplayPositionIndexToLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :logos, :display_pos_index, :integer
  end
end
