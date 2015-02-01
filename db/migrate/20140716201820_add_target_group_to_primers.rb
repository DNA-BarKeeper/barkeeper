class AddTargetGroupToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :target_group, :string
  end
end
