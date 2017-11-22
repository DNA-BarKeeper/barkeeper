class AddAttributesToContigSearch < ActiveRecord::Migration[5.0]
  def up
    add_column :contig_searches, :unassembled, :boolean
    add_column :contig_searches, :unverified, :boolean
  end

  def down
    remove_column :contig_searches, :unassembled
    remove_column :contig_searches, :unverified
  end
end
