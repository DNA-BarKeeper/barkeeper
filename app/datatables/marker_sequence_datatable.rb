# frozen_string_literal: true

class MarkerSequenceDatatable
  # TODO: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view

  def initialize(view, current_default_project)
    @view = view
    @current_default_project = current_default_project
  end

  def as_json(_options = {})
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
      species_name = ''
      species_id = 0

      if marker_sequence.try(:isolate).try(:individual).try(:species)
        species_name = marker_sequence.isolate.individual.species.name_for_display
        species_id = marker_sequence.isolate.individual.species.id
      end

      [
        link_to(marker_sequence.name, edit_marker_sequence_path(marker_sequence)),
        link_to(species_name, edit_species_path(species_id)),
        # species_name,
        marker_sequence.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', marker_sequence, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def marker_sequences
    @marker_sequences ||= fetch_marker_sequences
  end

  def fetch_marker_sequences
    marker_sequences = MarkerSequence.includes(:isolate).in_project(@current_default_project).order("#{sort_column} #{sort_direction}") # TODO: ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    marker_sequences = marker_sequences.page(page).per_page(per_page)

    if params[:sSearch].present?
      marker_sequences = marker_sequences.where('marker_sequences.name ILIKE :search', search: "%#{params[:sSearch]}%")
    end

    marker_sequences
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name species_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
