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

class MicronicPlateDatatable
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
      iTotalRecords: MicronicPlate.in_project(@current_default_project).count,
      iTotalDisplayRecords: micronic_plates.total_entries,
      aaData: data
    }
  end

  private

  def data
    micronic_plates.map do |micronic_plate|
      micronic_plate_id = ''
      if micronic_plate.micronic_plate_id
        micronic_plate_id = link_to micronic_plate.micronic_plate_id, edit_micronic_plate_path(micronic_plate)
      end

      lab_rack = ''
      shelf = ''
      freezer = ''

      if micronic_plate.lab_rack
        lab_rack = link_to micronic_plate.lab_rack.rackcode, edit_lab_rack_path(micronic_plate.lab_rack)
        shelf = link_to micronic_plate.lab_rack.shelf.name, edit_shelf_path(micronic_plate.lab_rack.shelf) if micronic_plate.lab_rack.shelf
        freezer = link_to micronic_plate.lab_rack.shelf&.freezer&.freezercode, edit_freezer_path(micronic_plate.lab_rack.shelf.freezer) if micronic_plate.lab_rack.shelf&.freezer
      end

      rack_position = micronic_plate.location_in_rack

      [
        micronic_plate_id,
        lab_rack,
        rack_position,
        shelf,
        freezer,
        micronic_plate.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', micronic_plate, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def micronic_plates
    @micronic_plates ||= fetch_micronic_plates
  end

  def fetch_micronic_plates
    micronic_plates = MicronicPlate.includes(lab_rack: [shelf: [freezer: :lab]]).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    micronic_plates = micronic_plates.page(page).per_page(per_page)

    if params[:sSearch].present?
      micronic_plates = micronic_plates.where('micronic_plates.micronic_plate_id ILIKE :search
OR lab_racks.rackcode ILIKE :search
OR micronic_plates.location_in_rack ILIKE :search
OR shelves.name ILIKE :search
OR freezers.freezercode ILIKE :search', search: "%#{params[:sSearch]}%")
                            .references(shelf: [freezer: :lab]) if params[:sSearch].present?
    end

    micronic_plates
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[micronic_plates.micronic_plate_id lab_racks.rackcode micronic_plates.location_in_rack shelves.name freezers.freezercode micronic_plates.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
