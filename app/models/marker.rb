class Marker < ApplicationRecord
  has_many :marker_sequences
  has_many :contigs
  has_many :primers
  has_and_belongs_to_many :higher_order_taxa
  has_and_belongs_to_many :projects

  validates_presence_of :name

  scope :gbol_marker, -> { where(:is_gbol => true) }

  def self.in_default_project(project_id)
    joins(:projects).where(projects: { id: project_id }).uniq
  end

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

    [ms.count, ms.uniq.count, ms_i.uniq.count]
  end
end
