class RemoveUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :oders
    drop_table :genera
    drop_table :contig_pde_uploaders
    drop_table :copies
    drop_table :helps
    drop_table :news
  end
end
