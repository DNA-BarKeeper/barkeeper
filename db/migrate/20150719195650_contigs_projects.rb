# frozen_string_literal: true

class ContigsProjects < ActiveRecord::Migration
  def change
    create_table :contigs_projects, id: false do |t|
      t.integer :contig_id
      t.integer :project_id
    end
  end
end
