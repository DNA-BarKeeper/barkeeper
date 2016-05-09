class AddImportedToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :imported, :boolean, :default => false
  end
end
