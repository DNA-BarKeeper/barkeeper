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

module OverviewDiagramConcern
  extend ActiveSupport::Concern

  def all_taxa_json(current_project_id)
    root = { :name => 'root', 'children' => [] }
    taxa = HigherOrderTaxon.in_project(current_project_id).includes(orders: [:families]).order(:position)
    species_count_per_family = Species.in_project(current_project_id).joins(:family).order('families.name').group('families.name').count

    i = 0
    taxa.each do |taxon|
      orders = taxon.orders
      children = root['children']
      children[i] = { :name => taxon.name, 'children' => [] }
      j = 0
      orders.each do |order|
        families = order.families
        children2 = children[i]['children']
        children2[j] = { :name => order.name, 'children' => [] }
        k = 0
        families.each do |family|
          children3 = children2[j]['children']
          children3[k] = { name: family.name, size: species_count_per_family[family.name].to_i }
          k += 1
        end
        j += 1
      end
      i += 1
    end

    root
  end

  def finished_taxa_json(current_project_id, marker_id)
    root = { :name => 'root', 'children' => [] }
    taxa = HigherOrderTaxon.in_project(current_project_id).includes(orders: [:families]).order(:position)
    marker_sequence_cnts = MarkerSequence.in_project(current_project_id).joins(isolate: [individual: [species: :family]]).where(marker: marker_id).order('families.name').group('families.name').count

    i = 0
    taxa.each do |taxon|
      orders = taxon.orders
      children = root['children']
      children[i] = { :name => taxon.name, 'children' => [] }
      j = 0
      orders.each do |order|
        families = order.families
        children2 = children[i]['children']
        children2[j] = { :name => order.name, 'children' => [] }
        k = 0
        families.each do |family|
          children3 = children2[j]['children']
          children3[k] = { name: family.name, size: marker_sequence_cnts[family.name].to_i }
          k += 1
        end
        j += 1
      end
      i += 1
    end

    root
  end
end
