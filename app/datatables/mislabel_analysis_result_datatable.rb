class MislabelAnalysisResultDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, analysis_id)
    @view = view
    @analysis_id = analysis_id
  end

  def as_json(options = {})
    {
        :sEcho => params[:sEcho].to_i,
        :iTotalRecords => MarkerSequence.count,
        :iTotalDisplayRecords => analysis_data.total_entries,
        :aaData => data
    }
  end

  private

  def data
    analysis_data.map do |mislabel|
      mislabel_level = mislabel.level
      mislabel_confidence = mislabel.confidence.to_f.round(2)
      proposed_label = mislabel.proposed_label

      species_name = ''
      species_id = 0

      if mislabel.marker_sequence.try(:isolate).try(:individual).try(:species)
        species_name = mislabel.marker_sequence.isolate.individual.species.name_for_display
        species_id = mislabel.marker_sequence.isolate.individual.species.id
      end

      [
          link_to(mislabel.marker_sequence.name, edit_marker_sequence_path(mislabel.marker_sequence)),
          link_to(species_name, edit_species_path(species_id)),
          mislabel_level,
          mislabel_confidence,
          proposed_label,
          mislabel.marker_sequence.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', mislabel.marker_sequence, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def analysis_data
    @analysis ||= MislabelAnalysis.find_by_id(@analysis_id).mislabels.joins(marker_sequence: [isolate: [individual: :species]]).reorder("#{sort_column} #{sort_direction}")

    @analysis = @analysis.page(page).per_page(per_page)

    if params[:sSearch].present?
      @analysis = @analysis.where("mislabels.marker_sequence.name ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    @analysis
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[marker_sequences.name individuals.species_id level confidence proposed_label marker_sequences.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end