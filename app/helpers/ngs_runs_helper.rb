module NgsRunsHelper
  def marker_headers
    headers = ''.dup

    Marker.gbol_marker.each do |marker|
      headers << "<th colspan=\"3\" style=\"text-align: center;\">#{marker.name}</th>"
    end

    headers.html_safe
  end

  def ngs_result_headers
    headers = ''.dup

    Marker.gbol_marker.size.times do
      headers << "<th data-orderable=\"false\">High Quality Sequences</th>"
      headers << "<th data-orderable=\"false\">Clusters</th>"
      headers << "<th data-orderable=\"false\">Incomplete Sequences</th>"
    end

    headers.html_safe
  end
end