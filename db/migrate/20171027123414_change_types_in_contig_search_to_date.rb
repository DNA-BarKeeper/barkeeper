class ChangeTypesInContigSearchToDate < ActiveRecord::Migration[5.0]
  def self.up
    change_column :contig_searches, :min_age, :date
    change_column :contig_searches, :max_age, :date
    change_column :contig_searches, :min_update, :date
    change_column :contig_searches, :max_update, :date
  end

  def self.down
    change_column :contig_searches, :min_age, :datetime
    change_column :contig_searches, :max_age, :datetime
    change_column :contig_searches, :min_update, :datetime
    change_column :contig_searches, :max_update, :datetime
  end
end
