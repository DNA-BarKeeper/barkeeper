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

class ContigSearchResultDatatable
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
      iTotalRecords: Contig.in_project(ContigSearch.find(@search_id).project&.id).count,
      iTotalDisplayRecords: contigs_data.total_entries,
      aaData: data
    }
  end

  private

  def data
    contigs_data.map do |contig|
      assembled = contig.assembled ? 'Yes' : 'No'
      taxon_name = ''
      taxon_id = 0
      individual_name = ''
      individual_id = 0

      if contig.try(:isolate).try(:individual).try(:taxon)
        taxon_name = contig.isolate.individual.taxon.scientific_name
        taxon_id = contig.isolate.individual.taxon.id
        individual_name = contig.isolate.individual.specimen_id
        individual_id = contig.isolate.individual.id
      end

      [
        link_to(contig.name, edit_contig_path(contig)),
        link_to(taxon_name, edit_taxon_path(taxon_id)),
        link_to(individual_name, edit_individual_path(individual_id)),
        assembled,
        contig.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', contig, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def contigs_data
    @search_result ||= ContigSearch.find_by_id(@search_id).contigs.includes(isolate: [individual: :taxon]).reorder("#{sort_column} #{sort_direction}")

    @search_result = @search_result.page(page).per_page(per_page)

    if params[:sSearch].present?
      @search_result = @search_result.where('contigs.name ILIKE :search OR taxa.scientific_name ILIKE :search OR individuals.specimen_id ILIKE :search', search: "%#{params[:sSearch]}%")
                                     .references(isolate: [individual: :taxon])
    end

    @search_result
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[contigs.name taxa.scientific_name individuals.specimen_id contigs.assembled contigs.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
