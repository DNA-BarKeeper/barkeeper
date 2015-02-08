class IsolateDatatable

  #ToDo: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view


  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Species.count,
        iTotalDisplayRecords: isolates.total_entries,
        aaData: data
    }
  end

  private

  def data
    isolates.map do |isolate|

      lab_nr=''
      if isolate.lab_nr
        lab_nr = link_to isolate.lab_nr, edit_isolate_path(isolate)
      end

      species_name = ''

      if isolate.individual and isolate.individual.species
        species_name = link_to isolate.individual.species.composed_name, edit_species_path(isolate.individual.species)
      end

      individual=''
      if isolate.individual and isolate.individual.specimen_id!=nil
        individual =link_to isolate.individual.specimen_id, edit_individual_path(isolate.individual)
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

    isolates = Isolate.order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    isolates = isolates.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      isolates = isolates.where("lab_nr like :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
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