class MarkerSequenceSearchResultDatatable

  #ToDo: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, search_id)
    @view = view
    @search_id = search_id
  end

  def as_json(options = {})
    {
        :sEcho => params[:sEcho].to_i,
        :iTotalRecords => MarkerSequence.count,
        :iTotalDisplayRecords => marker_sequences_data.total_entries,
        :aaData => data
    }
  end

  private

  def data
    marker_sequences_data.map do |ms|

      species_name = ''
      species_id = 0

      if ms.try(:isolate).try(:individual).try(:species)
        species_name = ms.isolate.individual.species.name_for_display
        species_id = ms.isolate.individual.species.id
      end

      [
          link_to(ms.name, edit_marker_sequence_path(ms)),
          link_to(species_name, edit_species_path(species_id)),
          ms.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', ms, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def marker_sequences_data
    @search_result ||= MarkerSequenceSearch.find_by_id(@search_id).marker_sequences.includes(isolate: [individual: :species]).reorder("#{sort_column} #{sort_direction}")

    @search_result = @search_result.page(page).per_page(per_page)

    if params[:sSearch].present?
      @search_result = @search_result.where("marker_sequences.name ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    @search_result
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[marker_sequences.name species_id marker_sequences.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end