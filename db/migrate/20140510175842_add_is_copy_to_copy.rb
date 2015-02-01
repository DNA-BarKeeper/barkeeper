class AddIsCopyToCopy < ActiveRecord::Migration
  def change
    add_column :copies, :isCopy, :boolean
  end
end
