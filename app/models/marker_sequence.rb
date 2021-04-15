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
  scope :has_taxon, -> { joins(isolate: [individual: :taxon]) }
  scope :no_isolate, -> { where(isolate: nil) }
  scope :unsolved_warnings, -> { joins(:mislabels).where(mislabels: { solved: false }) }

  after_save :update_finished_taxon_status
  after_destroy :update_finished_taxon_status

  # TODO: Remove
  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    ms = MarkerSequence.select('species_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    ms_s = MarkerSequence.select('species_component').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    ms_i = MarkerSequence.select('individual_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    [ms.count, ms_s.distinct.count, ms.distinct.count, ms_i.distinct.count]
  end

  def update_finished_taxon_status
    taxon = self.try(:isolate).try(:individual).try(:taxon)
    if taxon.try(:has_marker_sequence?)
      taxon.update(finished: true)
    else
      taxon.update(finished: false)
    end
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

  def isolate_display_name=(isolate_display_name)
    if isolate_display_name == ''
      self.isolate = nil
    elsif isolate_display_name.present?
      iso = Isolate.find_by(display_name: isolate_display_name)
      self.isolate = iso if iso
    end
  end

  def has_unsolved_mislabels
    mislabels.where(solved: false).present?
  end
end
