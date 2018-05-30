module ProjectHelper

  def user_projects
    current_user.admin? ? Project.all : current_user.projects
  end

  def taxa_grouped_select(results)
    groups = %w(HigherOrderTaxon Order Family Species)
    html = ''

    html << "<select id=\"taxa_id\" multiple=\"multiple\">"
    groups.each_with_index do |group, index|
      taxa = results.where(searchable_type: group)

      unless taxa.blank?
        html << "<optgroup label=\"#{group.titleize}\" class=\"group-#{index + 1}\">"

        taxa.each { |taxon| html << content_tag(:option, taxon.content, :value => taxon.searchable_id) }

        html << "</optgroup>"
      end
    end

    html << "</select>"

    html.html_safe
  end
end