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

class LabRackDatatable
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
      iTotalRecords: LabRack.in_project(@current_default_project).count,
      iTotalDisplayRecords: lab_racks.total_entries,
      aaData: data
    }
  end

  private

  def data
    lab_racks.map do |lab_rack|
      rackcode = ''

      rackcode = link_to lab_rack.rackcode, edit_lab_rack_path(lab_rack) if lab_rack.rackcode

      shelf = ''
      shelf = lab_rack.shelf.name if lab_rack.shelf

      freezer = ''
      lab = ''

      if lab_rack.shelf&.freezer
        freezer = link_to lab_rack.shelf.freezer.freezercode, edit_freezer_path(lab_rack.shelf.freezer)
        lab = link_to lab_rack.shelf.freezer.lab.labcode, edit_lab_path(lab_rack.shelf.freezer.lab) if lab_rack.shelf.freezer.lab
      end

      [
        rackcode,
        shelf,
        freezer,
        lab,
        lab_rack.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', lab_rack, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def lab_racks
    @lab_racks ||= fetch_lab_racks
  end

  def fetch_lab_racks
    lab_racks = LabRack.includes(shelf: [freezer: :lab]).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    lab_racks = lab_racks.page(page).per_page(per_page)

    lab_racks = lab_racks.where('lab_racks.rackcode ILIKE :search
OR shelves.name ILIKE :search
OR freezers.freezercode ILIKE :search
OR labs.labcode ILIKE :search', search: "%#{params[:sSearch]}%")
                    .references(shelf: [freezer: :lab]) if params[:sSearch].present?

    lab_racks
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[lab_racks.rackcode shelves.name freezers.freezercode labs.labcode lab_racks.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
