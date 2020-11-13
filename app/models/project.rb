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
  has_and_belongs_to_many :species
  has_and_belongs_to_many :families
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :higher_order_taxa

  has_and_belongs_to_many :labs
  has_and_belongs_to_many :freezers
  has_and_belongs_to_many :shelves
  has_and_belongs_to_many :lab_racks
  has_and_belongs_to_many :micronic_plates
  has_and_belongs_to_many :plant_plates

  has_and_belongs_to_many :ngs_runs
  has_and_belongs_to_many :clusters

  validates_presence_of :name

  def add_project_to_taxa(taxa_selection)
    taxa_selection[:hot]&.each { |hot_id| add_project_to_hot_rec(hot_id) }
    taxa_selection[:order]&.each { |order_id| add_project_to_order_rec(order_id) }
    taxa_selection[:family]&.each { |family_id| add_project_to_family_rec(family_id) }
    taxa_selection[:species]&.each { |species_id| Species.includes(:projects).find(species_id).add_project_and_save(id) unless species_id.blank? }
  end

  private

  def add_project_to_hot_rec(hot_id)
    unless hot_id.blank?
      hot = HigherOrderTaxon.includes(:projects).find(hot_id)
      hot.add_project_and_save(id)
      hot.orders.each { |o| add_project_to_order_rec(o.id) }
    end
  end

  def add_project_to_order_rec(order_id)
    unless order_id.blank?
      order = Order.includes(:projects).find(order_id)
      order.add_project_and_save(id)
      order.families.each { |f| add_project_to_family_rec(f.id) }
    end
  end

  def add_project_to_family_rec(family_id)
    unless family_id.blank?
      family = Family.includes(:projects).find(family_id)
      family.add_project_and_save(id)
      family.species.each { |s| s.add_project_and_save(id) }
    end
  end
end
