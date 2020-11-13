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

class FreezerDatatable
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
      iTotalRecords: Freezer.in_project(@current_default_project).count,
      iTotalDisplayRecords: freezers.total_entries,
      aaData: data
    }
  end

  private

  def data
    freezers.map do |freezer|
      freezercode = ''

      freezercode = link_to freezer.freezercode, edit_freezer_path(freezer) if freezer.freezercode

      lab = ''
      lab = link_to freezer.lab.labcode, edit_lab_path(freezer.lab) if freezer.lab

      [
        freezercode,
        lab,
        freezer.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', freezer, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def freezers
    @freezers ||= fetch_freezers
  end

  def fetch_freezers
    freezers = Freezer.includes(:lab).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    freezers = freezers.page(page).per_page(per_page)

    if params[:sSearch].present?
      freezers = freezers.where('freezers.freezercode ILIKE :search OR labs.labcode ILIKE :search', search: "%#{params[:sSearch]}%")
                         .references(:lab)
    end

    freezers
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[freezers.freezercode labs.labcode freezers.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
