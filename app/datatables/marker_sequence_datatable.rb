class MarkerSequenceDatatable

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
        iTotalRecords: MarkerSequence.count,
        iTotalDisplayRecords: marker_sequences.total_entries,
        aaData: data
    }
  end

  private

  def data

    marker_sequences.map do |marker_sequence|

      sp=""
      if marker_sequence.isolate and marker_sequence.isolate.individual and marker_sequence.isolate.individual.species
        sp=marker_sequence.isolate.individual.species.name_for_display
      end
      [
          link_to(marker_sequence.name, edit_marker_sequence_path(marker_sequence)),
          sp,
          marker_sequence.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', marker_sequence, method: :delete, data: { confirm: 'Are you sure?' }),
      ]
    end
  end

  def marker_sequences
    @marker_sequences ||= fetch_marker_sequences
  end

  def fetch_marker_sequences

    marker_sequences = MarkerSequence.includes(:isolate).order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    marker_sequences = marker_sequences.page(page).per_page(per_page)

    if params[:sSearch].present?
        marker_sequences = marker_sequences.where("name like :search", search: "%#{params[:sSearch]}%") #  todo --> fix to use case-insensitive / postgres
    end
    marker_sequences
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name isolate_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end