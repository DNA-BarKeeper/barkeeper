module NgsRunsHelper
  def marker_headers(ngs_run)
    headers = ''.dup

    ngs_run.markers.order(:id).distinct.each do |marker|
      headers << "<th colspan=\"3\" style=\"text-align: center;\">#{marker.name}</th>"
    end

    headers.html_safe
  end

  def ngs_result_headers(ngs_run)
    headers = ''.dup

    ngs_run.markers.distinct.size.times do
      headers << "<th data-orderable=\"false\">High Quality Sequences</th>"
      headers << "<th data-orderable=\"false\">Incomplete Sequences</th>"
      headers << "<th data-orderable=\"false\">Clusters</th>"
    end

    headers.html_safe
  end

  def tag_primer_maps(ngs_run)
    if ngs_run.tag_primer_maps.size > 1
      tpms = '<ul>'.dup

      ngs_run.tag_primer_maps.includes([tag_primer_map_attachment: :blob]).each do |tpm|
        tpms << "<li>#{tpm.tag_primer_map.filename}</li>"
      end

      tpms << '</ul>'
      tpms = tpms.html_safe
    else
      tpms = ngs_run.tag_primer_maps.first.tag_primer_map.filename
    end

    tpms
  end
end