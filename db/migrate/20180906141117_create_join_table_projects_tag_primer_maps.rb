class CreateJoinTableProjectsTagPrimerMaps < ActiveRecord::Migration[5.0]
  def change
    create_join_table :projects, :tag_primer_maps do |t|
      t.index [:project_id, :tag_primer_map_id], name: 'index_projects_tag_primer_maps'
    end
  end
end
