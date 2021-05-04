# frozen_string_literal: true

class OrphanedTaxaDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, current_default_project)
    @view = view
    @current_default_project = current_default_project
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Taxon.orphans.count,
      iTotalDisplayRecords: orphans.total_entries,
      aaData: data
    }
  end

  private

  def data
    orphans.map do |orphan|
      [
        link_to(orphan.scientific_name, edit_taxon_path(orphan)),
        orphan.synonym,
        orphan.common_name,
        orphan.human_taxonomic_rank,
        orphan.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', orphan, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def orphans
    @orphans ||= fetch_orphans
  end

  def fetch_orphans
    orphans = Taxon.orphans.in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    orphans = orphans.page(page).per_page(per_page)

    if params[:sSearch].present?
      orphans = orphans.where('taxa.scientific_name ILIKE :search OR taxa.synonym ILIKE :search
OR taxa.common_name ILIKE :search', search: "%#{params[:sSearch]}%")
    end

    orphans
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
