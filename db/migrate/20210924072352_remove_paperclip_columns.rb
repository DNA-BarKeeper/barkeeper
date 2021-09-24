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
