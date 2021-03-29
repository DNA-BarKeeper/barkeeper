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
      taxon_path = ''
      family_path = ''

      if isolate.try(:individual).try(:taxon)
        taxon_id = isolate.individual.taxon_id
        taxon_path = link_to(isolate.individual.taxon.scientific_name, edit_taxon_path(taxon_id)) if taxon_id

        if isolate.try(:individual).try(:taxon).parent
          family = isolate.individual.taxon.ancestors.where(taxonomic_rank: :is_family).first
          family_path = link_to(family.scientific_name, edit_taxon_path(family.id)) if family
        end
      end

      values = [
          link_to(isolate.display_name, edit_isolate_path(isolate)),
          taxon_path,
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
                             .includes(individual: :taxon)
                             .distinct
                             .reorder("#{sort_column} #{sort_direction}")

    if params[:sSearch].present?
      @analysis_result = @analysis_result
                             .where('isolates.display_name ILIKE :search OR taxa.scientific_name ILIKE :search', search: "%#{params[:sSearch]}%")
                             .references(individual: :taxon)
    end

    @analysis_result
  end

  def sort_column
    columns = %w[isolates.display_name taxa.scientific_name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
