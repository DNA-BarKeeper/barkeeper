# frozen_string_literal: true

class AddSubdivisionIdToTaxonomicClasses < ActiveRecord::Migration
  def change
    add_column :taxonomic_classes, :subdivision_id, :integer
  end
end
