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

class IssueDatatable
  # TODO: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.

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
      iTotalRecords: Issue.in_project(@current_default_project).count,
      iTotalDisplayRecords: issues.total_entries,
      aaData: data
    }
  end

  private

  def data
    issues.map do |issue|
      primer_read_link = ' '
      primer_read_link = link_to(issue.primer_read.name, edit_primer_read_path(issue.primer_read)) if issue.primer_read

      contig_link = ' '
      contig_link = link_to issue.contig.name, edit_contig_path(issue.contig) if issue.contig

      [
        link_to(issue.title, edit_issue_path(issue)),
        primer_read_link,
        contig_link,
        issue.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', issue, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def issues
    @issues ||= fetch_issues
  end

  def fetch_issues
    issues = Issue.in_project(@current_default_project).order("#{sort_column} #{sort_direction}") # TODO: ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    issues = issues.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      issues = issues.where('issues.title ILIKE :search', search: "%#{params[:sSearch]}%") # TODO: --> fix to use case-insensitive / postgres
    end
    issues
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title primer_read_id contig_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
