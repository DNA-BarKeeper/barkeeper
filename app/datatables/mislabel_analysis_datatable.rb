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

class MislabelAnalysisDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: MislabelAnalysis.count,
      iTotalDisplayRecords: analyses.total_entries,
      aaData: data
    }
  end

  private

  def data
    analyses.map do |analysis|
      [
        link_to(analysis.title, mislabel_analysis_path(analysis)),
        analysis.mislabels.size,
        analysis.total_seq_number,
        analysis.created_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', analysis, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def analyses
    @analyses = MislabelAnalysis.includes(:mislabels).order("#{sort_column} #{sort_direction}")
    @analyses = @analyses.page(page).per_page(per_page)

    if params[:sSearch].present?
      @analyses = @analyses.where('mislabel_analyses.title ILIKE :search', search: "%#{params[:sSearch]}%")
    end

    @analyses
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title id total_seq_number created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
