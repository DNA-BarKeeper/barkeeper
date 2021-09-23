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

module HomesHelper
  def main_project_logo
    if @home.main_logo && @home.main_logo.image&.attached? && @home.main_logo.display
      content_tag :a, href: @home.main_logo.url do
        content_tag :img, '', alt: 'project_logo', width: 140, class: 'pull-right', src: url_for(@home.main_logo.image)
      end
    end
  end

  def about_subtitle
    if @home.subtitle
      content_tag :small, @home.subtitle
    end
  end

  def about_description
    if @home.description
      content_tag :small, @home.description
    end
  end

  def display_project_logos
    logos_html = +''.html_safe

    if @home.logos.size.positive?
      partner_logos = @home.logos.where(display: true).where(main: false).with_attached_image
      partner_logos.order(:display_pos_index).each do |logo|
        if logo.image.attached? && logo.url
          logos_html << (content_tag :div, style: 'height: 70px;', class: "col-sm-#{partner_logos.size}" do
            content_tag :a, href: logo.url, target: '_blank' do
              image_tag url_for(logo.image), title: logo.title, class: 'partner_logo'
            end
          end)
        end
      end
    end

    logos_html
  end

  def multisearch_results(results)
    results.map do |result|
      content_tag :p do
        case result.searchable_type
        when 'Freezer'
          result_title = result.searchable.freezercode
        when 'Individual'
          result_title = result.searchable.specimen_id
        when 'Isolate'
          result_title = result.searchable.display_name
        when 'Lab'
          result_title = result.searchable.labcode
        when 'LabRack'
          result_title = result.searchable.rackcode
        when 'Taxon'
          result_title = result.searchable.scientific_name
        else
          result_title = result.searchable.name
        end

        # result_title +=  ' (' + result.searchable_type + ')'
        result_type = result.searchable_type.to_s.underscore

        content_tag(:span, content_tag(:b, result.searchable_type + ':'), class: 'multisearch-result-entry') +
          content_tag(:span, link_to(result_title, send("edit_#{result_type}_path", result.searchable_id)), class: 'multisearch-result-entry')
      end
    end.join.html_safe
  end
end