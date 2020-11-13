#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
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

  def isolate_display_name=(isolate_display_name)
    if isolate_display_name == ''
      self.isolate = nil
    elsif isolate_display_name.present?
      iso = Isolate.find_by(display_name: isolate_display_name)
      self.isolate = iso if iso
    end
  end

  def has_unsolved_mislabels
    !mislabels.where(solved: false).blank?
  end
end
