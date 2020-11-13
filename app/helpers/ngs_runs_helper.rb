#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
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