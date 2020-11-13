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

    lineage_str = +''.html_safe

    lineage.each_with_index do |taxon, i|
      tax_entity = PgSearch.multisearch(taxon)[0]

      if tax_entity&.content == taxon
        tax_object = tax_entity.searchable_type.constantize.find(tax_entity.searchable_id)
        taxon_display = link_to(tax_object.name, edit_polymorphic_path(tax_object))
      end

      taxon_display ||= taxon

      lineage_str << "- " * i
      lineage_str << taxon_display
      lineage_str << tag(:br)
    end

    lineage_str
  end
end