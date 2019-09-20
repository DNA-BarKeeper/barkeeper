# frozen_string_literal: true

class IsolateDatatable
  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view

  def initialize(view, isolates_to_show, current_default_project)
    @view = view
    @isolates_to_show = isolates_to_show
    @current_default_project = current_default_project
  end

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Isolate.in_project(@current_default_project).count,
      iTotalDisplayRecords: isolates.total_entries,
      aaData: data
    }
  end

  private

  def data
    isolates.map do |isolate|

      dna_bank_id = ''
      dna_bank_id = link_to isolate.dna_bank_id, edit_isolate_path(isolate) if isolate.dna_bank_id

      lab_isolation_nr = ''
      lab_isolation_nr = link_to isolate.lab_isolation_nr, edit_isolate_path(isolate) if isolate.lab_isolation_nr

      species_name = ''
      species_name = link_to isolate.individual.species.name_for_display, edit_species_path(isolate.individual.species) if isolate.individual&.species

      individual = ''
      if isolate.individual && !isolate.individual.specimen_id.nil?
        individual = link_to isolate.individual.specimen_id, edit_individual_path(isolate.individual)
      end

      [
        dna_bank_id,
        lab_isolation_nr,
        species_name,
        individual,
        isolate.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', isolate, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def isolates
    @isolates ||= fetch_isolates
  end

  def fetch_isolates
    case @isolates_to_show
    when 'no_specimen'
      isolates = Isolate.includes(individual: :species).where(individual: nil).where(negative_control: false).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    when 'duplicates' # Either have duplicate DNA Bank Number or Lab Isolation Number
      names_with_multiple_db = Isolate.group(:dna_bank_id).having('count(dna_bank_id) > 1').count.keys
      names_with_multiple_gbol = Isolate.group(:lab_isolation_nr).having('count(lab_isolation_nr) > 1').count.keys
      isolates = Isolate.includes(individual: :species).in_project(@current_default_project)
                        .where(dna_bank_id: names_with_multiple_db + names_with_multiple_gbol).order("#{sort_column} #{sort_direction}")
    else
      isolates = Isolate.includes(individual: :species).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    end

    isolates = isolates.page(page).per_page(per_page)

    if params[:sSearch].present?
      isolates = isolates.where('isolates.dna_bank_id ILIKE :search
OR isolates.lab_isolation_nr ILIKE :search
OR species.composed_name ILIKE :search
OR individuals.specimen_id ILIKE :search', search: "%#{params[:sSearch]}%")
                         .references(individual: :species)
    end

    isolates
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[isolates.dna_bank_id isolates.lab_isolation_nr species.composed_name individuals.specimen_id isolates.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
