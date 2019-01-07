# frozen_string_literal: true

class HigherOrderTaxaProjects < ActiveRecord::Migration
  def change
    create_table :higher_order_taxa_projects, id: false do |t|
      t.integer :higher_order_taxon_id
      t.integer :project_id
    end
  end
end
