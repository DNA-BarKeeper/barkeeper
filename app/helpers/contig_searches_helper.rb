#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

# frozen_string_literal: true

module ContigSearchesHelper
  def result_archive_desc(contig_search)
    if contig_search.search_result_archive.attached?
      content_tag('p',
                          "The current result archive was created at #{contig_search.search_result_archive.created_at}. To download an archive reflecting the most recent state of the database please create a new one on the server.")
    else
      content_tag('p',
                          "No result archive is currently stored on the server. Please create one to download detailed results including pherograms or try reloading the page.")
    end
  end

  def result_archive_download(contig_search)
    if contig_search.search_result_archive.attached?
      link_to("Download existing result archive including pherograms (*.zip)",
              contig_search_download_results_path(contig_search),
              class: 'btn btn-default')
    end
  end
end