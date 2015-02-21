class SpeciesDatatable

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
        iTotalDisplayRecords: species.total_entries,
        aaData: data
    }
  end

  private

  def data
    species.map do |single_species|

      family=''
      if single_species.family
        family=link_to(single_species.family.name, edit_family_path(single_species.family))
      end
      [
          link_to(single_species.name_for_display, edit_species_path(single_species)),
          single_species.author,
          family,
          single_species.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', single_species, method: :delete, data: { confirm: 'Are you sure?' }),
      ]
    end
  end

  def species
    @species ||= fetch_species
  end

  def fetch_species

    species = Species.order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    species = species.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      species = species.where("composed_name like :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
    end
    species
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[composed_name author family_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end