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

class ClusterDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, isolate_id, current_default_project)
    @view = view
    @isolate_id = isolate_id
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
      taxon_name = ''
      taxon_id = 0
      individual_name = ''
      individual_id = 0

      if cluster.try(:isolate).try(:individual).try(:taxon)
        taxon_name = cluster.isolate.individual.taxon.scientific_name
        taxon_id = cluster.isolate.individual.taxon.id
        individual_name = cluster.isolate.individual.specimen_id
        individual_id = cluster.isolate.individual.id
      end

      [
          link_to(cluster.name, cluster_path(cluster)),
          link_to(cluster.ngs_run.name, edit_ngs_run_path(cluster.ngs_run)),
          link_to(taxon_name, edit_taxon_path(taxon_id)),
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
    if @isolate_id
      clusters = Cluster.includes(:ngs_run, isolate: [individual: :taxon])
                     .where(isolate_id: @isolate_id)
                     .in_project(@current_default_project)
                     .order("#{sort_column} #{sort_direction}")
    else
      clusters = Cluster.includes(:ngs_run, isolate: [individual: :taxon])
                     .in_project(@current_default_project)
                     .order("#{sort_column} #{sort_direction}")
    end

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
    columns = %w[clusters.name ngs_runs.name taxa.scientific_name individuals.specimen_id clusters.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
