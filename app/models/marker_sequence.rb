# frozen_string_literal: true

class MarkerSequence < ApplicationRecord
  include ProjectRecord

  has_many :contigs
  has_many :mislabels, dependent: :destroy
  has_and_belongs_to_many :mislabel_analyses
  belongs_to :marker
  belongs_to :isolate

  scope :verified, -> { joins(:contigs).where(contigs: { verified: true }) }
  scope :not_verified, -> { joins(:contigs).where(contigs: { verified: false }) }
  scope :has_species, -> { joins(isolate: [individual: :species]) }
  scope :no_isolate, -> { where(isolate: nil) }
  scope :unsolved_warnings, -> { joins(:mislabels).where(mislabels: { solved: false }) }

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    ms = MarkerSequence.select('species_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    ms_s = MarkerSequence.select('species_component').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    ms_i = MarkerSequence.select('individual_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    [ms.count, ms_s.distinct.count, ms.distinct.count, ms_i.distinct.count]
  end

  def generate_name
    if marker.present? && isolate.present?
      update(name: "#{isolate.display_name}_#{marker.name}")
    else
      update(name: '<unnamed>')
    end
  end

  def isolate_display_name
    isolate.try(:display_name)
  end

  def isolate_lab_isolation_nr=(lab_isolation_nr)
    if lab_isolation_nr == ''
      self.isolate = nil
    else
      self.isolate = Isolate.find_or_create_by(lab_isolation_nr: lab_isolation_nr) if lab_isolation_nr.present? # TODO is it used? Add project if so
    end
  end

  def has_unsolved_mislabels
    !mislabels.where(solved: false).blank?
  end
end
