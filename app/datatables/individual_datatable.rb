class IndividualDatatable

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
        iTotalRecords: Individual.count,
        iTotalDisplayRecords: individuals.total_entries,
        aaData: data
    }
  end

  private

  def data
    individuals.map do |individual|

      species=''
      if individual.species
        species=link_to individual.species.name_for_display, edit_species_path(individual.species)
      end
      [
          link_to(individual.specimen_id, edit_individual_path(individual)),
          species,
          individual.herbarium,
          individual.collector,
          individual.collection_nr,
          individual.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', individual, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def individuals
    @individuals ||= fetch_individuals
  end

  def fetch_individuals

    individuals = Individual.includes(:species).order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    individuals = individuals.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      individuals = individuals.where("specimen_id like :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
    end
    individuals
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[specimen_id species_id herbarium collector collection_nr updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end