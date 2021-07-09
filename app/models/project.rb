# frozen_string_literal: true

class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :contig_searches
  has_many :marker_sequence_searches
  has_many :individual_searches

  has_and_belongs_to_many :issues

  has_and_belongs_to_many :primers
  has_and_belongs_to_many :markers

  has_and_belongs_to_many :isolates
  has_and_belongs_to_many :primer_reads
  has_and_belongs_to_many :contigs
  has_and_belongs_to_many :marker_sequences

  has_and_belongs_to_many :individuals
  has_and_belongs_to_many :taxa

  has_and_belongs_to_many :labs
  has_and_belongs_to_many :freezers
  has_and_belongs_to_many :shelves
  has_and_belongs_to_many :lab_racks
  has_and_belongs_to_many :micronic_plates
  has_and_belongs_to_many :plant_plates

  has_and_belongs_to_many :ngs_runs
  has_and_belongs_to_many :clusters

  validates_presence_of :name

  def add_project_to_taxonomy(parent_taxon_id)
    parent_taxon = Taxon.find(parent_taxon_id) if parent_taxon_id
    if parent_taxon
      parent_taxon.subtree.includes(:projects).each do |taxon|
        taxon.add_project_and_save(id)
      end
    end
  end
end
