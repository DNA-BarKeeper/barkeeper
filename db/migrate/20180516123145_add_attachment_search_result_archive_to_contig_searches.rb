class AddAttachmentSearchResultArchiveToContigSearches < ActiveRecord::Migration[5.0]
  def self.up
    change_table :contig_searches do |t|
      t.attachment :search_result_archive
    end
  end

  def self.down
    remove_attachment :contig_searches, :search_result_archive
  end
end
