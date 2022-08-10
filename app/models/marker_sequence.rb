#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

# frozen_string_literal: true

class MarkerSequence < ApplicationRecord
  include ProjectRecord

  has_many :contigs, dependent: :nullify
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
