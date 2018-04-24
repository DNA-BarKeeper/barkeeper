class AddProjectToContigSearch < ActiveRecord::Migration[5.0]
  def change
    add_reference :contig_searches, :project, foreign_key: true
  end
end
