# frozen_string_literal: true

class TaxonDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, parent_id, current_default_project)
    @view = view
    @parent_id = parent_id
    @current_default_project = current_default_project
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Taxon.in_project(@current_default_project).count,
      iTotalDisplayRecords: taxa.total_entries,
      aaData: data
    }
  end

  private

  def data
    taxa.map do |taxon|
      [
        link_to(taxon.scientific_name, edit_taxon_path(taxon)),
        taxon.synonym,
        taxon.common_name,
        taxon.human_taxonomic_rank,
        taxon.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', taxon, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def taxa
    @taxa ||= fetch_taxa
  end

  def fetch_taxa
    if @parent_id
      taxa = Taxon.find(@parent_id)&.children&.in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    else
      taxa = Taxon.orphans.in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    end

    taxa = taxa.page(page).per_page(per_page)

    if params[:sSearch].present?
      taxa = taxa.where('taxa.scientific_name ILIKE :search OR taxa.synonym ILIKE :search
OR taxa.common_name ILIKE :search', search: "%#{params[:sSearch]}%")
    end

    taxa
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[taxa.scientific_name taxa.synonym taxa.common_name taxa.taxonomic_rank taxa.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
