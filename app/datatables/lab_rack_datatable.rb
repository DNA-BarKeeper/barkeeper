class LabRackDatatable

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view


  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: LabRack.count,
        iTotalDisplayRecords: lab_racks.total_entries,
        aaData: data
    }
  end

  private

  def data
    lab_racks.map do |lab_rack|

      rackcode=''

      if lab_rack.rackcode
        rackcode = link_to lab_rack.rackcode, edit_lab_rack_path(lab_rack)
      end

      rack_position=''
      if lab_rack.rack_position
        rack_position=lab_rack.rack_position
        end

      shelf=''
      if lab_rack.shelf
        shelf=lab_rack.shelf
      end

      freezer=''
      lab=''
      if lab_rack.freezer
        freezer=link_to lab_rack.freezer.freezercode, edit_freezer_path(lab_rack.freezer)
        if lab_rack.freezer.lab
          lab = link_to lab_rack.freezer.lab.labcode, edit_lab_path(lab_rack.freezer.lab)
        end
      end


      [
          rackcode,
          rack_position,
          shelf,
          freezer,
          lab,
          lab_rack.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', lab_rack, method: :delete, data: { confirm: 'Are you sure?' })
      ]

    end

  end

  def lab_racks
    @freezers ||= fetch_freezers
  end

  def fetch_freezers

    freezers = LabRack.order("#{sort_column} #{sort_direction}")

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
    columns = %w[rackcode rack_position shelf freezer lab updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end