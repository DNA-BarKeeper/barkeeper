# frozen_string_literal: true

class NgsRunResultDatatable
  # TODO: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, analysis_id)
    @view = view
    @analysis_id = analysis_id
  end

  def as_json(_options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: NgsRun.find_by_id(@analysis_id).isolates.distinct.size,
        iTotalDisplayRecords: isolates_data.size,
        aaData: data
    }
  end

  private

  def data
    isolates_data.map do |isolate|
      species_path = ''
      family_path = ''

      if isolate.try(:individual).try(:species).try(:family)
        species_id = isolate.individual.species.id
        species_path = link_to(isolate.individual.species.name_for_display, edit_species_path(species_id)) if species_id
        family_id = isolate.individual.species.family.id
        family_path = link_to(isolate.individual.species.family.name, edit_family_path(family_id)) if family_id
      end

      values = [
          link_to(isolate.display_name, edit_isolate_path(isolate)),
          species_path,
          family_path,
          NgsResult.where(ngs_run_id: @analysis_id, isolate: isolate).sum(:total_sequences)
      ]

      NgsRun.find_by_id(@analysis_id).markers.order(:id).distinct.each do |marker|
        result = NgsResult.where(marker: marker, ngs_run_id: @analysis_id, isolate: isolate).first

        if result
          values << result.hq_sequences
          values << result.incomplete_sequences
          values << link_to(result.cluster_count, edit_isolate_path(isolate, anchor: "assigned_clusters"))
        else
          3.times { values << "NA" }
        end
      end

      values
    end
  end

  def isolates_data
    @analysis_result ||= NgsRun.find_by_id(@analysis_id)
                             .isolates
                             .includes(individual: [species: :family])
                             .distinct
                             .reorder("#{sort_column} #{sort_direction}")

    if params[:sSearch].present?
      @analysis_result = @analysis_result
                             .where('isolates.display_name ILIKE :search OR species.composed_name ILIKE :search OR families.name ILIKE :search', search: "%#{params[:sSearch]}%")
                             .references(individual: [species: :family])
    end

    @analysis_result
  end

  def sort_column
    columns = %w[isolates.display_name species.composed_name families.name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
