class FreezerDatatable

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
        iTotalRecords: Freezer.count,
        iTotalDisplayRecords: freezers.total_entries,
        aaData: data
    }
  end

  private

  def data
    freezers.map do |freezer|

      freezercode=''

      if freezer.freezercode
        freezercode = link_to freezer.freezercode, edit_freezer_path(freezer)
      end

      lab=''
      if freezer.lab
        lab = link_to freezer.lab.labcode, edit_lab_path(freezer.lab)
      end

      [
          freezercode,
          lab,
          freezer.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', freezer, method: :delete, data: { confirm: 'Are you sure?' })
      ]

    end

  end

  def freezers
    @freezers ||= fetch_freezers
  end

  def fetch_freezers

    freezers = Freezer.in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    freezers = freezers.page(page).per_page(per_page)

    if params[:sSearch].present?
      freezers = freezers.where("freezercode ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    freezers
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[freezercode lab updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end