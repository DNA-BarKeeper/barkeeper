class AddVerifiedToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :verified, :boolean, :default => false
  end
end
