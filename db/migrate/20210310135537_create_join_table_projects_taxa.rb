class CreateJoinTableProjectsTaxa < ActiveRecord::Migration[5.2]
  def change
    create_join_table :projects, :taxa do |t|
      t.index [:project_id, :taxon_id]
    end
  end
end
