# frozen_string_literal: true

class Marker < ApplicationRecord
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  has_many :clusters
  has_many :ngs_results
  has_many :primers
  has_many :mislabel_analyses
  has_and_belongs_to_many :higher_order_taxa

  validates_presence_of :name

  scope :gbol_marker, -> { in_project(Project.find_by_name('GBOL5')) }

  def spp_in_higher_order_taxon(higher_order_taxon_id)
    ms = MarkerSequence.select('species_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } })
                       .where(orders: { higher_order_taxon_id: higher_order_taxon_id }, marker_sequences: { marker_id: id })
    ms_i = MarkerSequence.select('individual_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } })
                         .where(orders: { higher_order_taxon_id: higher_order_taxon_id }, marker_sequences: { marker_id: id })

    [ms.count, ms.distinct.count, ms_i.distinct.count]
  end
end
