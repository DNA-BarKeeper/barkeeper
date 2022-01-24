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

module ClustersHelper
  def reverse_complement(reverse)
    if reverse
      content_tag(:span, '', class: %w(glyphicon glyphicon-ok-circle), style: 'color: green;')
    else
      content_tag(:span, '', class: %w(glyphicon glyphicon-remove-circle), style: 'color: red;')
    end
  end

  def blast_warning(blast_hit)
    if blast_hit && blast_hit.taxonomy.split(',')[0] != "Embryophyta"
      color = 'red'
    else
      color = 'grey'
    end

    "color: #{color}"
  end

  def taxonomic_lineage(taxonomy)
    lineage = taxonomy.split(',')

    lineage_str = ''.dup

    lineage.each_with_index do |taxon_name, i|
      taxon = Taxon.find_by_scientific_name(taxon_name)
      taxon_display = link_to(taxon.scientific_name, edit_polymorphic_path(taxon)) if taxon

      taxon_display ||= taxon_name

      lineage_str << "- " * i
      lineage_str << taxon_display
      lineage_str << "<br>"
    end

    lineage_str.html_safe
  end
end