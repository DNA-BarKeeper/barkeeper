class AddNotesToPrimers < ActiveRecord::Migration
  def change
    add_column :primers, :notes, :text
  end
end
