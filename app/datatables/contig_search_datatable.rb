class ContigSearchDatatable

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
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Contig.count,
        iTotalDisplayRecords: contigs_data.count,
        aaData: data
    }
  end

  private

  def data
    contigs_data.map do |contig|

      assembled='No'
      if contig.assembled
        assembled='Yes'
      end

      species_name=''
      species_id=0
      individual_name=''
      individual_id=0

      if contig.try(:isolate).try(:individual).try(:species)
        species_name=contig.isolate.individual.species.name_for_display
        species_id=contig.isolate.individual.species.id
        individual_name=contig.isolate.individual.specimen_id
        individual_id=contig.isolate.individual.id
      end

      [
          link_to(contig.name, edit_contig_path(contig)),
          link_to(species_name, edit_species_path(species_id)),
          link_to(individual_name, edit_individual_path(individual_id)),
          assembled,
          contig.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', contig, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def contigs_data
    @search_result ||= ContigSearch.find_by_id(@search_id).contigs.order("#{sort_column} #{sort_direction}")

    @search_result = @search_result.page(page).per_page(per_page)

    if params[:sSearch].present?
      @search_result = @search_result.where("contigs.name ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    @search_result
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name species_id individual_id assembled updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end