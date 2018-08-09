module ProjectHelper

  def user_projects
    current_user.admin? ? Project.all : current_user.projects
  end

  def taxa_selects(results)
    groups = %w(HigherOrderTaxon Order Family Species)
    html = ''

    groups.each do |group|
      taxa = results.where(searchable_type: group)

      unless taxa.blank?
        html << '<div>'
        html << label(group.downcase.to_sym, group.titleize)
        html << '<br>'
        html << collection_select(group.downcase.to_sym, :id, @result.where(searchable_type: group), :searchable_id, :content, {}, { multiple: true, class: 'form-control' })
        html << '</div>'
        html << '<br>'
      end
    end

    html.html_safe
  end

  def taxa_grouped_select(results)
    groups = %w(HigherOrderTaxon Order Family Species)
    html = ''
    optgroups = ''

    groups.each_with_index do |group, index|
      taxa = results.where(searchable_type: group)
      options = ''

      unless taxa.blank?
        taxa.each { |taxon| options << content_tag(:option, taxon.content, :value => taxon.searchable_id) }

        optgroups << content_tag(:optgroup, options.html_safe, label: group.titleize, class: "group-#{index + 1}")
      end
    end

    html << select_tag(:taxa, optgroups.html_safe, { multiple: true }) #html << '<select id=\"taxa_id\" name=\"taxa[id][]\" multiple=\"multiple\">'

    html.html_safe
  end

  def taxon_select(result, taxon_type)
    taxa = result.where(searchable_type: taxon_type)
    html = ''
    options = ''

    taxa.each { |taxon| options << content_tag(:option, taxon.content, :value => taxon.searchable_id) } unless taxa.blank?

    html << select_tag(:taxa, options.html_safe, { multiple: true, name: taxon_type.titleize })

    html.html_safe
  end
end