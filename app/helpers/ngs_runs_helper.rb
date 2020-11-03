module NgsRunsHelper
  def marker_headers(ngs_run)
    headers = +''.html_safe

    ngs_run.markers.order(:id).distinct.each do |marker|
      headers << content_tag(:th, marker.name, colspan: 3, style: 'text-align: center;')
    end

    headers
  end

  def ngs_result_headers(ngs_run)
    headers = +''.html_safe

    ngs_run.markers.distinct.size.times do
      headers << content_tag(:th, 'High Quality Sequences', data: { orderable: false })
      headers << content_tag(:th, 'Incomplete Sequences', data: { orderable: false })
      headers << content_tag(:th, 'Clusters', data: { orderable: false })
    end

    headers
  end

  def tag_primer_maps(ngs_run)
    tpms = +''.html_safe

    if ngs_run.tag_primer_maps.size > 1
      tpms << content_tag(:ul) do
        ngs_run.tag_primer_maps.collect do |tpm|
          content_tag(:li, tpm.tag_primer_map.filename)
        end.join.html_safe
      end
    else
      tpms = ngs_run.tag_primer_maps.first.tag_primer_map.filename
    end

    tpms
  end
end