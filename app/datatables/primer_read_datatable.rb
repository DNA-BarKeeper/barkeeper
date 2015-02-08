class PrimerReadDatatable

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
        iTotalRecords: Species.count,
        iTotalDisplayRecords: primer_reads.total_entries,
        aaData: data
    }
  end

  private

  def data
    primer_reads.map do |pr|

      contig_link = ""

      unless pr.contig.nil?
        contig_link = link_to(pr.contig.name, edit_contig_path(pr.contig))
      end

      [
          link_to(pr.name, edit_primer_read_path(pr)),
          pr.assembled,
          contig_link,
          pr.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
          link_to('Delete', pr, method: :delete, data: { confirm: 'Are you sure?' }),
      ]
    end
  end

  def primer_reads
    @primer_reads ||= fetch_reads
  end

  def fetch_reads

    primer_reads = PrimerRead.includes(:contig).select("name, assembled, updated_at, contig_id, id").order("#{sort_column} #{sort_direction}") # todo ---> maybe add find_each (batches!) later -if possible, probably conflicts with sorting
    primer_reads = primer_reads.page(page).per_page(per_page)

    if params[:sSearch].present?
      # WORKS?: species = species.where("name like :search or family like :search", search: "%#{params[:sSearch]}%")
      primer_reads = primer_reads.where("name like :search", search: "%#{params[:sSearch]}%") # todo --> fix to use case-insensitive / postgres
    end
    primer_reads
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name assembled contig_id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end