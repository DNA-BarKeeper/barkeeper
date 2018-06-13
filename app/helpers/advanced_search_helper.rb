module AdvancedSearchHelper
  def title(search)
    "- #{search.title unless search.title.blank?}"
  end

  def project(search)
    search.project.name if search.project
  end

  def attributes(search)
    exclude = %w[id title project_id user_id created_at updated_at]
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
      when 'has_species'
        "Is assigned to a species"
      else
        "#{k.titleize}: #{v}"
      end
    end
    output.join(', ')
  end

  private

  def format_date(date)
    date.strftime('%d.%m.%Y')
  end
end