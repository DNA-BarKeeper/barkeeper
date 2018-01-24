class ContigSearchDatatable

  #ToDo: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, current_user_id)
    @view = view
    @current_user_id = current_user_id
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: ContigSearch.where.not(:title => '').count,
        iTotalDisplayRecords: searches.total_entries,
        aaData: data
    }
  end

  private

  def data
    searches.map do |search|
      [
          link_to(search.title, contig_search_path(search)),
          search.created_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', search, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def searches
    @searches = ContigSearch.where.not(title: '').where(:user_id => @current_user_id).order("#{sort_column} #{sort_direction}")

    @searches = @searches.page(page).per_page(per_page)

    if params[:sSearch].present?
      @searches = @searches.where("contig_searches.title ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    @searches
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end