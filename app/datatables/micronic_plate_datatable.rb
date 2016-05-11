class MicronicPlateDatatable

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view


  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: PlantPlate.count,
        iTotalDisplayRecords: plant_plates.total_entries,
        aaData: data
    }
  end

  private

  def data
    plant_plates.map do |micronic_plate|

      micronic_plate_id=''
      if micronic_plate.micronic_plate_id
        name = link_to micronic_plate.micronic_plate_id, edit_micronic_plate_path(micronic_plate)
      end

      lab_rack=''
      rack_position=''
      shelf=''
      freezer=''

      if micronic_plate.lab_rack
        lab_rack = link_to micronic_plate.lab_rack.rackcode, edit_lab_rack_path(micronic_plate.lab_rack)
        rack_position = micronic_plate.lab_rack.rack_position
        shelf= micronic_plate.lab_rack.shelf
        if micronic_plate.lab_rack.freezer
          freezer=micronic_plate.lab_rack.freezer.freezercode
        end
      end

      [
          name,
          lab_rack,
          rack_position,
          shelf,
          freezer,
          micronic_plate.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', micronic_plate, method: :delete, data: { confirm: 'Are you sure?' })
      ]

    end

  end

  def plant_plates
    @freezers ||= fetch_plant_plates
  end

  def fetch_plant_plates

    plant_plates = MicronicPlate.order("#{sort_column} #{sort_direction}")

    plant_plates = plant_plates.page(page).per_page(per_page)

    if params[:sSearch].present?
      plant_plates = plant_plates.where("name ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    plant_plates
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name lab_rack rack_position shelf freezer updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

