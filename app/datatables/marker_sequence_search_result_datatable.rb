#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
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
      iTotalRecords: MarkerSequence.in_project(MarkerSequenceSearch.find(@search_id).project&.id).count,
      iTotalDisplayRecords: marker_sequences_data.total_entries,
      aaData: data
    }
  end

  private

  def data
    marker_sequences_data.map do |marker_sequence|
      taxon_name = ''
      taxon_id = 0

      if marker_sequence.try(:isolate).try(:individual).try(:taxon)
        taxon_name = marker_sequence.isolate.individual.taxon.scientific_name
        taxon_id = marker_sequence.isolate.individual.taxon.id
      end

      [
        link_to(marker_sequence.name, edit_marker_sequence_path(marker_sequence)),
        link_to(taxon_name, edit_taxon_path(taxon_id)),
        marker_sequence.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', marker_sequence, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def marker_sequences_data
    @search_result ||= MarkerSequenceSearch.find_by_id(@search_id).marker_sequences.includes(isolate: [individual: :taxon]).reorder("#{sort_column} #{sort_direction}")

    @search_result = @search_result.page(page).per_page(per_page)

    if params[:sSearch].present?
      @search_result = @search_result.where('marker_sequences.name ILIKE :search
OR taxa.scientific_name ILIKE :search', search: "%#{params[:sSearch]}%")
                           .references(isolate: [individual: :taxon])
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
    columns = %w[marker_sequences.name taxa.scientific_name marker_sequences.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
