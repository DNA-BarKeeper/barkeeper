# frozen_string_literal: true

class ChangeTypesInContigSearch < ActiveRecord::Migration[5.0]
  def self.up
    remove_column :contig_searches, :min_age
    remove_column :contig_searches, :max_age
    remove_column :contig_searches, :min_update
    remove_column :contig_searches, :max_update

    add_column :contig_searches, :min_age, :datetime
    add_column :contig_searches, :max_age, :datetime
    add_column :contig_searches, :min_update, :datetime
    add_column :contig_searches, :max_update, :datetime
  end

  def self.down
    remove_column :contig_searches, :min_age
    remove_column :contig_searches, :max_age
    remove_column :contig_searches, :min_update
    remove_column :contig_searches, :max_update

    add_column :contig_searches, :min_age, :decimal
    add_column :contig_searches, :max_age, :decimal
    add_column :contig_searches, :min_update, :decimal
    add_column :contig_searches, :max_update, :decimal
  end
end
