class ContigDatatable

  #ToDo: fig out if this inclusion is necessary. Found on https://gist.github.com/jhjguxin/4544826, but unclear if makes sense. "delegate" statement alone does not work.

  include Rails.application.routes.url_helpers
  delegate :url_helpers, to: 'Rails.application.routes'

  delegate :params, :link_to, :h, to: :@view

  def initialize(view, need_verify, imported, duplicates)
    @view = view
    @need_verify = need_verify
    @imported = imported
    @duplicates = duplicates
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Contig.count,
        iTotalDisplayRecords: contigs.total_entries,
        aaData: data
    }
  end

  private

  def data
    contigs.map do |contig|

      assembled='No'
      if contig.assembled
        assembled='Yes'
      end

      species_name=''
      species_id=0

      if contig.try(:isolate).try(:individual).try(:species)
        species_name=contig.isolate.individual.species.name_for_display
        species_id=contig.isolate.individual.species.id
      end

      [
          # check_box_tag("contig_ids[]", contig.id),
          link_to(contig.name, edit_contig_path(contig)),
          link_to(species_name, edit_species_path(species_id)),
          assembled,
          contig.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', contig, method: :delete, data: { confirm: 'Are you sure?' })
      ]
    end
  end

  def contigs
    @contigs ||= fetch_contigs
  end

  def fetch_contigs

    if @duplicates

      names_with_multiple = Contig.group(:name).having("count(name) > 1").count.keys

      contigs=Contig.where(name: names_with_multiple).order("name")

    elsif @need_verify
      contigs = Contig.assembled_need_verification.order("#{sort_column} #{sort_direction}")
    elsif @imported
      contigs=Contig.externally_edited.order("#{sort_column} #{sort_direction}")
    else
      contigs = Contig.order("#{sort_column} #{sort_direction}")
    end

    contigs = contigs.page(page).per_page(per_page)

    if params[:sSearch].present?
      contigs = contigs.where("name ILIKE :search", search: "%#{params[:sSearch]}%")
    end
    contigs
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name species_id assembled updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end