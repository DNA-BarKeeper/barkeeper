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

class PrimerReadDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, reads_to_show, current_default_project)
    @view = view
    @reads_to_show = reads_to_show
    @current_default_project = current_default_project
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: PrimerRead.in_project(@current_default_project).count,
      iTotalDisplayRecords: primer_reads.total_entries,
      aaData: data
    }
  end

  private

  def data
    primer_reads.map do |pr|
      read_name = pr.processed ? link_to(pr.name, edit_primer_read_path(pr)) : pr.name
      assembled = pr.assembled ? 'Yes' : 'No'
      contig_link = pr.contig.nil? ? '' : link_to(pr.contig.name, edit_contig_path(pr.contig))
      delete = pr.processed ? link_to('Delete', pr, method: :delete, data: { confirm: 'Are you sure?' }) : 'Processing...'

      [
        read_name,
        assembled,
        contig_link,
        pr.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        delete
      ]
    end
  end

  def primer_reads
    @primer_reads ||= fetch_reads
  end

  def fetch_reads
    # TODO: Maybe add find_each (batches!) later - if possible, probably conflicts with sorting
    case @reads_to_show
    when 'without_contig'
      primer_reads = PrimerRead.includes(:contig).where(contig: nil)
                               .select(:name, :processed, :assembled, :updated_at, :contig_id, :id)
                               .in_project(@current_default_project)
                               .order("#{sort_column} #{sort_direction}")
    when 'with_issues'
      primer_reads = PrimerRead.includes(:contig).unsolved_issues
                               .select(:name, :processed, :assembled, :updated_at, :contig_id, :id)
                               .in_project(@current_default_project)
                               .order("#{sort_column} #{sort_direction}")
    else
      primer_reads = PrimerRead.includes(:contig)
                               .select(:name, :processed, :assembled, :updated_at, :contig_id, :id)
                               .in_project(@current_default_project)
                               .order("#{sort_column} #{sort_direction}")
    end

    primer_reads = primer_reads.page(page).per_page(per_page)

    if params[:sSearch].present?
      primer_reads = primer_reads.where('primer_reads.name ILIKE :search OR contigs.name ILIKE :search', search: "%#{params[:sSearch]}%").references(:contig)
    end

    primer_reads
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[primer_reads.name primer_reads.assembled contigs.name primer_reads.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
