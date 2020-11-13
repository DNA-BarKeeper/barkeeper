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

module ProjectsHelper
  def user_projects
    current_user.admin? ? Project.all : current_user.projects
  end

  def taxa_selects(results)
    groups = %w[HigherOrderTaxon Order Family Species]
    html = ''.html_safe

    groups.each do |group|
      taxa = results.where(searchable_type: group)

      next if taxa.blank?

      html += content_tag(:div) do
        label(group.downcase.to_sym, group.titleize) +
        tag(:br) +
        collection_select(group.downcase.to_sym, :id, @result.where(searchable_type: group),
                          :searchable_id, :content, {}, multiple: true)
      end

      html += tag(:br)
    end

    html
  end

  # def taxa_grouped_select(results)
  #   groups = %w[HigherOrderTaxon Order Family Species]
  #   html = +''
  #   optgroups = +''
  #
  #   groups.each_with_index do |group, index|
  #     taxa = results.where(searchable_type: group)
  #     options = +''
  #
  #     next if taxa.blank?
  #     taxa.each { |taxon| options << content_tag(:option, taxon.content, value: taxon.searchable_id) }
  #
  #     optgroups << content_tag(:optgroup, options.html_safe, label: group.titleize, class: "group-#{index + 1}")
  #   end
  #
  #   html << select_tag(:taxa, optgroups.html_safe, multiple: true) # html << '<select id=\"taxa_id\" name=\"taxa[id][]\" multiple=\"multiple\">'
  #
  #   html.html_safe
  # end
  #
  # def taxon_select(result, taxon_type)
  #   taxa = result.where(searchable_type: taxon_type)
  #   html = +''
  #   options = +''
  #
  #   taxa.each { |taxon| options << content_tag(:option, taxon.content, value: taxon.searchable_id) } unless taxa.blank?
  #
  #   html << select_tag(:taxa, options.html_safe, multiple: true, name: taxon_type.titleize)
  #
  #   html.html_safe
  # end
end
