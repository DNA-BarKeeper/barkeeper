# frozen_string_literal: true

class SpeciesDatatable
  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view

  def initialize(view, family_id, higher_order_id, current_default_project)
    @view = view
    @family_id = family_id
    @higher_order_id = higher_order_id
    @current_default_project = current_default_project
  end

  def as_json(_options = {})
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
      family = ''
      family = link_to(single_species.family.name, edit_family_path(single_species.family)) if single_species.family
      [
        link_to(single_species.name_for_display, edit_species_path(single_species)),
        single_species.author,
        family,
        single_species.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S'),
        link_to('Delete', single_species, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def species
    @species ||= fetch_species
  end

  def fetch_species
    if @higher_order_id
      species = Species.includes(:family).joins(family: { order: :higher_order_taxon }).where(orders: { higher_order_taxon_id: @higher_order_id }).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    elsif @family_id
      species = Species.includes(:family).where(family_id: @family_id).in_project(@current_default_project).order("#{sort_column} #{sort_direction}") # TODO: ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    else
      species = Species.includes(:family).in_project(@current_default_project).order("#{sort_column} #{sort_direction}") # TODO: ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    end
    species = species.page(page).per_page(per_page)

    species = species.where('species.composed_name ILIKE :search
OR species.author ILIKE :search
OR families.name ILIKE :search', search: "%#{params[:sSearch]}%")
                     .references(:family) if params[:sSearch].present?

    species
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[species.composed_name species.author families.name species.updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end
