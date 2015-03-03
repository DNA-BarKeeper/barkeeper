class ContigDatatable

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
      [
          link_to(contig.name, edit_contig_path(contig)),
          assembled,
          contig.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', contig, method: :delete, data: { confirm: 'Are you sure?' }),
      ]
    end
  end

  def contigs
    @contigs ||= fetch_contigs
  end

  def fetch_contigs

    contigs = Contig.order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    contigs = contigs.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      contigs = contigs.where("name ILIKE :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
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
    columns = %w[name assembled updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end