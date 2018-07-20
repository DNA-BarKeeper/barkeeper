class PrimerReadDatatable
  include Rails.application.routes.url_helpers

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :params, :link_to, :h, to: :@view

  def initialize(view, reads_to_show, current_default_project)
    @view = view
    @reads_to_show = reads_to_show
    @current_default_project = current_default_project
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: PrimerRead.count,
      iTotalDisplayRecords: primer_reads.total_entries,
      aaData: data
    }
  end

  private

  def data
    primer_reads.map do |pr|
      read_name = pr.processed ? link_to(pr.name, edit_primer_read_path(pr)) : pr.name
      assembled = pr.assembled ? 'Yes' : 'No'
      contig_link = pr.contig.nil? ? '' : link_to(pr.contig.name, edit_contig_path(pr.contig))
      delete = pr.processed ? link_to('Delete', pr, method: :delete, data: { confirm: 'Are you sure?' }) : 'Processing...'

      [
        read_name,
        assembled,
        contig_link,
        pr.updated_at.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:%S"),
        delete
      ]
    end
  end

  def primer_reads
    @primer_reads ||= fetch_reads
  end

  def fetch_reads
    # TODO: Maybe add find_each (batches!) later - if possible, probably conflicts with sorting
    case @reads_to_show
    when 'duplicates'
      files_with_multiple = PrimerRead.select(:chromatogram_fingerprint).group(:chromatogram_fingerprint).having("count(primer_reads.chromatogram_fingerprint) > 1").count.keys
      primer_reads = PrimerRead.includes(:contig).in_project(@current_default_project).where(chromatogram_fingerprint: files_with_multiple).select(:name, :processed, :assembled, :updated_at, :contig_id, :id).order("#{sort_column} #{sort_direction}")
    when 'no_contig'
      primer_reads = PrimerRead.includes(:contig).where(:contig => nil).select(:name, :processed, :assembled, :updated_at, :contig_id, :id).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    else
      primer_reads = PrimerRead.includes(:contig).select(:name, :processed, :assembled, :updated_at, :contig_id, :id).in_project(@current_default_project).order("#{sort_column} #{sort_direction}")
    end

    primer_reads = primer_reads.page(page).per_page(per_page)

    if params[:sSearch].present?
      primer_reads = primer_reads.where("primer_reads.name ILIKE :search", search: "%#{params[:sSearch]}%")
    end

    primer_reads
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i.positive? ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name assembled contigs.id updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end
end