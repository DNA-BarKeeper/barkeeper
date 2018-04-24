module PrimerReadsHelper
  def render_primer_read_list(all_reads)
    all_reads.map do |primer_read|
      render primer_read
    end.join.html_safe
  end
end
