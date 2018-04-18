class IsolateDatatable

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view

  def initialize(view, no_specimen, current_default_project)
    @view = view
    @no_specimen = no_specimen
    @current_default_project = current_default_project
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Isolate.count,
      iTotalDisplayRecords: isolates.total_entries,
      aaData: data
    }
  end

  private
  def data
    isolates.map do |isolate|

      lab_nr = ''
      lab_nr = link_to isolate.lab_nr, edit_isolate_path(isolate) if isolate.lab_nr

      species_name = ''
      species_name = link_to isolate.individual.species.name_for_display, edit_species_path(isolate.individual.species) if isolate.individual and isolate.individual.species

      individual = ''
      if isolate.individual && !isolate.individual.specimen_id.nil?
        individual = link_to isolate.individual.specimen_id, edit_individual_path(isolate.individual)
      end

      [
        lab_nr,
        species_name,
        individual,
        isolate.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
        link_to('Delete', isolate, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def isolates
    @isolates ||= fetch_isolates
  end

  def fetch_isolates
    if @no_specimen
      isolates = Isolate.includes(:individual => :species).where(:individual => nil).where(:negative_control => false).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    else
      # for standard index view
      isolates = Isolate.includes(:individual => :species).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    end

    isolates = isolates.page(page).per_page(per_page)

    if params[:sSearch].present?
      isolates = isolates.where("lab_nr ILIKE :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
    end

    isolates
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[lab_nr individual_id individual_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end