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

class CollectionDatatable
  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(_options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Collection.count,
        iTotalDisplayRecords: collections.total_entries,
        aaData: data
    }
  end

  private

  def data
    collections.map do |collection|
      name = ''

      name = link_to collection.name, edit_collection_path(collection) if collection.name

      [
          name,
          collection.acronym,
          collection.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
          link_to('Delete', collection, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def collections
    @collections ||= fetch_collections
  end

  def fetch_collections
    collections = Collection.all.order("#{sort_column} #{sort_direction}")

    collections = collections.page(page).per_page(per_page)

    if params[:sSearch].present?
      collections = collections.where('collections.name ILIKE :search OR collections.acronym ILIKE :search', search: "%#{params[:sSearch]}%")
    end

    collections
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[collections.name collections.acronym collections.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
