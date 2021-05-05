module AdvancedSearchesHelper
  def title(search)
    "'#{search.title}'" unless search.title.blank?
  end

  def project(search)
    search.project.name if search.project
  end

  def attributes(search)
    exclude = %w[id title project_id user_id search_result_archive_content_type search_result_archive_file_name
                  search_result_archive_file_size search_result_archive_updated_at created_at updated_at]
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