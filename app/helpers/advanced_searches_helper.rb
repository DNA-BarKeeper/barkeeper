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
module AdvancedSearchesHelper
  def title(search)
    "'#{search.title}'" unless search.title.blank?
  end

  def project(search)
    search.project.name if search.project
  end

  def attributes(search)
    exclude = %w[id title project_id user_id created_at updated_at]
    output_text = {
        all_issue: 'Has issues: both',
        issues: 'Has issues: yes',
        no_issues: 'Has issues: no',
        all_taxon: 'Has taxon info: both',
        taxon: 'Has taxon info: yes',
        no_taxon: 'Has taxon info: no',
        all_location: 'Location data status: both',
        bad_location: 'Location data status: problematic',
        location_okay: 'Location data status: okay'
    }

    attributes = search.attributes.sort.select { |k, v| !v.blank? && !exclude.include?(k) }
    output = attributes.collect do |k, v|
      case k
      when 'min_age'
        "Created since: #{format_date(v)}"
      when 'max_age'
        "Created before: #{format_date(v)}"
      when 'min_update'
        "Updated since: #{format_date(v)}"
      when 'max_update'
        "Updated before: #{format_date(v)}"
      when 'min_length'
        "Length minimum: #{v}"
      when 'max_length'
        "Length maximum: #{v}"
      else
        if v.is_a?(String) && output_text[v.to_sym]
          output_text[v.to_sym]
        else
          "#{k.titleize}: #{v}"
        end
      end
    end

    output.join(', ')
  end

  def radio_checked(search, attribute, value)
    current_value = search.send(attribute)

    if current_value && current_value != value
      false
    else
      true
    end
  end

  private

  def format_date(date)
    date.strftime('%d.%m.%Y')
  end
end