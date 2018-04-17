class IssueDatatable

  #ToDo: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view


  def initialize(view, current_default_project)
    @view = view
    @current_default_project = current_default_project
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Issue.count,
        iTotalDisplayRecords: issues.total_entries,
        aaData: data
    }
  end

  private

  def data
    issues.map do |issue|

      primer_read_link=' '
      if issue.primer_read
        primer_read_link=link_to(issue.primer_read.name, edit_primer_read_path(issue.primer_read))
      end

      contig_link=' '
      if issue.contig
        contig_link=link_to issue.contig.name, edit_contig_path(issue.contig)
      end

      [
          link_to(issue.title, edit_issue_path(issue)),
          primer_read_link,
          contig_link,
          issue.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', issue, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def issues
    @issues ||= fetch_issues
  end

  def fetch_issues

    issues = Issue.in_default_project(@current_default_project).order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    issues = issues.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      issues = issues.where("title ILIKE :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
    end
    issues
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title primer_read_id contig_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end