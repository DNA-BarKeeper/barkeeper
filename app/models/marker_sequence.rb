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
