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

class MarkerSequenceSearchResultDatatable
  # TODO: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, search_id)
    @view = view
    @search_id = search_id
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: MarkerSequence.in_project(MarkerSequenceSearch.find(@search_id).project.id).count,
      iTotalDisplayRecords: marker_sequences_data.total_entries,
      aaData: data
    }
  end

  private

  def data
    marker_sequences_data.map do |ms|
      species_name = ''
      species_id = 0

      if ms.try(:isolate).try(:individual).try(:species)
        species_name = ms.isolate.individual.species.name_for_display
        species_id = ms.isolate.individual.species.id
      end

      [
        link_to(ms.name, edit_marker_sequence_path(ms)),
        link_to(species_name, edit_species_path(species_id)),
        ms.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', ms, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def marker_sequences_data
    @search_result ||= MarkerSequenceSearch.find_by_id(@search_id).marker_sequences.includes(isolate: [individual: :species]).reorder("#{sort_column} #{sort_direction}")

    @search_result = @search_result.page(page).per_page(per_page)

    if params[:sSearch].present?
      @search_result = @search_result.where('marker_sequences.name ILIKE :search
OR species.composed_name ILIKE :search', search: "%#{params[:sSearch]}%")
                           .references(isolate: [individual: :species])
    end

    @search_result
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[marker_sequences.name species.composed_name marker_sequences.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
