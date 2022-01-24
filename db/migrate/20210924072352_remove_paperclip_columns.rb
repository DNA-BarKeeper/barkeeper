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
class RemovePaperclipColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :contig_searches, :search_result_archive_content_type
    remove_column :contig_searches, :search_result_archive_file_name
    remove_column :contig_searches, :search_result_archive_file_size
    remove_column :contig_searches, :search_result_archive_updated_at

    remove_column :ngs_runs, :results_content_type
    remove_column :ngs_runs, :results_file_name
    remove_column :ngs_runs, :results_file_size
    remove_column :ngs_runs, :results_updated_at

    remove_column :ngs_runs, :set_tag_map_content_type
    remove_column :ngs_runs, :set_tag_map_file_name
    remove_column :ngs_runs, :set_tag_map_file_size
    remove_column :ngs_runs, :set_tag_map_updated_at

    remove_column :primer_reads, :chromatogram_content_type
    remove_column :primer_reads, :chromatogram_file_name
    remove_column :primer_reads, :chromatogram_file_size
    remove_column :primer_reads, :chromatogram_updated_at

    remove_column :tag_primer_maps, :tag_primer_map_content_type
    remove_column :tag_primer_maps, :tag_primer_map_file_name
    remove_column :tag_primer_maps, :tag_primer_map_file_size
    remove_column :tag_primer_maps, :tag_primer_map_updated_at

    remove_column :txt_uploaders, :uploaded_file_content_type
    remove_column :txt_uploaders, :uploaded_file_file_name
    remove_column :txt_uploaders, :uploaded_file_file_size
    remove_column :txt_uploaders, :uploaded_file_updated_at
  end
end
