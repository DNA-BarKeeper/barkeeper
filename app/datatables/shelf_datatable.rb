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

class ShelfDatatable
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
      iTotalRecords: Shelf.in_project(@current_default_project).count,
      iTotalDisplayRecords: shelves.total_entries,
      aaData: data
    }
  end

  private

  def data
    shelves.map do |shelf|
      shelf_name = link_to shelf.name, edit_shelf_path(shelf)

      freezer = ''

      if shelf.freezer
        freezer = link_to shelf.freezer.freezercode, edit_freezer_path(shelf.freezer)
      end

      [
        shelf_name,
        freezer,
        shelf.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', shelf, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def shelves
    @shelves ||= fetch_shelves
  end

  def fetch_shelves
    shelves = Shelf.includes(:freezer).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    shelves = shelves.page(page).per_page(per_page)

    if params[:sSearch].present?
      shelves = shelves.where('shelves.name ILIKE :search
OR freezers.freezercode ILIKE :search', search: "%#{params[:sSearch]}%")
                                       .references(shelf: [freezer: :lab]) if params[:sSearch].present?
    end

    shelves
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[shelves.name freezers.freezercode shelves.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
