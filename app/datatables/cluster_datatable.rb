# frozen_string_literal: true

class ClusterDatatable
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
        iTotalRecords: Cluster.count,
        iTotalDisplayRecords: clusters.total_entries,
        aaData: data
    }
  end

  private

  def data
    clusters.map do |cluster|
      species_name = ''
      species_id = 0
      individual_name = ''
      individual_id = 0

      if cluster.try(:isolate).try(:individual).try(:species)
        species_name = cluster.isolate.individual.species.name_for_display
        species_id = cluster.isolate.individual.species.id
        individual_name = cluster.isolate.individual.specimen_id
        individual_id = cluster.isolate.individual.id
      end

      [
          link_to(cluster.name, edit_cluster_path(cluster)),
          link_to(cluster.ngs_run.analysis_name, edit_ngs_run_path(cluster.ngs_run)),
          link_to(species_name, edit_species_path(species_id)),
          link_to(individual_name, edit_individual_path(individual_id)),
          cluster.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
          link_to('Delete', cluster, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def clusters
    @clusters ||= fetch_clusters
  end

  def fetch_clusters
    clusters = Cluster.includes(:ngs_run, isolate: [individual: :species]).order("#{sort_column} #{sort_direction}")

    clusters = clusters.page(page).per_page(per_page)

    clusters = clusters.where('clusters.name ILIKE :search', search: "%#{params[:sSearch]}%") if params[:sSearch].present?

    clusters
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[clusters.name ngs_runs.analysis_name species.composed_name individuals.specimen_id clusters.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
