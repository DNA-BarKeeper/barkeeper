class Marker < ApplicationRecord
  include ProjectModule

  has_many :marker_sequences
  has_many :contigs
  has_many :primers
  has_and_belongs_to_many :higher_order_taxa
  has_and_belongs_to_many :projects, -> { distinct }

  validates_presence_of :name

  scope :gbol_marker, -> { where(:is_gbol => true) }

  def spp_in_higher_order_taxon(higher_order_taxon_id)
    ms = MarkerSequence.select("species_id").includes(:isolate => :individual).joins(:isolate =>
                                                                                       { :individual =>
                                                                                            { :species =>
                                                                                                 { :family =>
                                                                                                      { :order => :higher_order_taxon }}}}).
        where(orders: { higher_order_taxon_id: higher_order_taxon_id }, marker_sequences: { marker_id: self.id })
    ms_i = MarkerSequence.select("individual_id").includes(:isolate => :individual).joins(:isolate =>
                                                                                       {:individual =>
                                                                                            {:species =>
                                                                                                 {:family =>
                                                                                                      {:order => :higher_order_taxon}}}}).
        where(orders: { higher_order_taxon_id: higher_order_taxon_id }, marker_sequences: { marker_id: self.id })

    [ms.count, ms.distinct.count, ms_i.distinct.count]
  end
end
