module ProjectHelper

  def user_projects
    current_user.admin? ? Project.all : current_user.projects
  end

  def taxon_search_result(result, taxon_type)
    taxa = result.where(searchable_type: taxon_type)
    html = ''

    unless taxa.blank?
      html << "<strong>#{taxon_type.titleize}:</strong><br>"
      html << '<ul>'

      taxa.each do |taxon|
        html << content_tag(:li, taxon.content)
      end

      html << '</ul><br>'

      html.html_safe
    end
  end
end