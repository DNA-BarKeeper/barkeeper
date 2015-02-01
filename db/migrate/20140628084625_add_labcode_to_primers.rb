class AddLabcodeToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :labcode, :string
  end
end
