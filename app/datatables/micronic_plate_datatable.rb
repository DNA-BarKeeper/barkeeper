class MicronicPlateDatatable

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
      iTotalRecords: MicronicPlate.count,
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
      rack_position = ''
      shelf = ''
      freezer = ''

      if micronic_plate.lab_rack
        lab_rack = link_to micronic_plate.lab_rack.rackcode, edit_lab_rack_path(micronic_plate.lab_rack)
        shelf = micronic_plate.lab_rack.shelf
        if micronic_plate.lab_rack.freezer
          freezer = micronic_plate.lab_rack.freezer.freezercode
        end
      end

      rack_position = micronic_plate.location_in_rack

      [
        micronic_plate_id,
        lab_rack,
        rack_position,
        shelf,
        freezer,
        micronic_plate.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
        link_to('Delete', micronic_plate, method: :delete, data: { confirm: 'Are you sure?' })
      ]

    end

  end

  def micronic_plates
    @micronic_plates ||= fetch_micronic_plates
  end

  def fetch_micronic_plates
    micronic_plates = MicronicPlate.in_project(@current_default_project).order("#{sort_column} #{sort_direction}")

    micronic_plates = micronic_plates.page(page).per_page(per_page)

    if params[:sSearch].present?
      micronic_plates = micronic_plates.where("name ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    micronic_plates
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[micronic_plate_id lab_rack rack_position shelf freezer updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

