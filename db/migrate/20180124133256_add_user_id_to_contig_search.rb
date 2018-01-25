class AddUserIdToContigSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :contig_searches, :user_id, :integer
  end
end
