class ChangeBooleansInContigSearch < ActiveRecord::Migration[5.0]
  def up
    change_column :contig_searches, :assembled, :string
    change_column :contig_searches, :verified, :string
    remove_column :contig_searches, :unassembled
    remove_column :contig_searches, :unverified
  end

  def down
    change_column :contig_searches, :assembled, :boolean
    change_column :contig_searches, :verified, :boolean
    add_column :contig_searches, :unassembled, :boolean
    add_column :contig_searches, :unverified, :boolean
  end
end
