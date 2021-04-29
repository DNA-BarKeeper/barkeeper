# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_27_115411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "aliquots", id: :serial, force: :cascade do |t|
    t.text "comment"
    t.decimal "concentration"
    t.string "well_pos_micronic_plate"
    t.integer "lab_id"
    t.integer "micronic_plate_id"
    t.integer "isolate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "micronic_tube"
    t.boolean "is_original", default: false
    t.index ["isolate_id"], name: "index_aliquots_on_isolate_id"
    t.index ["lab_id"], name: "index_aliquots_on_lab_id"
    t.index ["micronic_plate_id"], name: "index_aliquots_on_micronic_plate_id"
  end

  create_table "blast_hits", id: :serial, force: :cascade do |t|
    t.integer "cluster_id"
    t.string "taxonomy"
    t.decimal "e_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cluster_id"], name: "index_blast_hits_on_cluster_id"
  end

  create_table "clusters", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "centroid_sequence"
    t.integer "sequence_count"
    t.string "fasta"
    t.boolean "reverse_complement"
    t.integer "isolate_id"
    t.integer "ngs_run_id"
    t.integer "marker_id"
    t.integer "running_number"
    t.string "name"
    t.index ["isolate_id"], name: "index_clusters_on_isolate_id"
    t.index ["marker_id"], name: "index_clusters_on_marker_id"
    t.index ["ngs_run_id"], name: "index_clusters_on_ngs_run_id"
  end

  create_table "clusters_projects", id: false, force: :cascade do |t|
    t.integer "cluster_id", null: false
    t.integer "project_id", null: false
    t.index ["cluster_id", "project_id"], name: "index_clusters_projects_on_cluster_id_and_project_id"
  end

  create_table "contig_pde_uploaders", id: :serial, force: :cascade do |t|
    t.string "uploaded_file_file_name"
    t.string "uploaded_file_content_type"
    t.integer "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contig_searches", id: :serial, force: :cascade do |t|
    t.string "taxon"
    t.string "specimen"
    t.string "verified"
    t.string "marker"
    t.string "name"
    t.string "assembled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "min_age"
    t.date "max_age"
    t.date "min_update"
    t.date "max_update"
    t.string "title"
    t.integer "user_id"
    t.integer "project_id"
    t.string "search_result_archive_file_name"
    t.string "search_result_archive_content_type"
    t.integer "search_result_archive_file_size"
    t.datetime "search_result_archive_updated_at"
    t.integer "has_warnings"
    t.string "verified_by"
    t.index ["project_id"], name: "index_contig_searches_on_project_id"
  end

  create_table "contigs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "consensus"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "marker_sequence_id"
    t.integer "isolate_id"
    t.integer "marker_id"
    t.boolean "assembled"
    t.boolean "assembly_tried"
    t.text "fas"
    t.boolean "verified", default: false
    t.integer "verified_by"
    t.datetime "verified_at"
    t.string "comment"
    t.boolean "imported", default: false
    t.integer "partial_cons_count"
    t.integer "overlap_length", default: 15
    t.integer "allowed_mismatch_percent", default: 5
  end

  create_table "contigs_projects", id: false, force: :cascade do |t|
    t.integer "contig_id"
    t.integer "project_id"
  end

  create_table "copies", id: :serial, force: :cascade do |t|
    t.string "well_pos_plant_plate"
    t.integer "lab_nr"
    t.integer "micronic_tube_id"
    t.string "well_pos_micronic_plate"
    t.decimal "concentration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "divisions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "families", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "author", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "order_id"
  end

  create_table "families_projects", id: false, force: :cascade do |t|
    t.integer "family_id"
    t.integer "project_id"
  end

  create_table "freezers", id: :serial, force: :cascade do |t|
    t.string "freezercode", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "lab_id"
  end

  create_table "freezers_projects", id: false, force: :cascade do |t|
    t.integer "freezer_id", null: false
    t.integer "project_id", null: false
    t.index ["freezer_id", "project_id"], name: "index_freezers_projects_on_freezer_id_and_project_id"
  end

  create_table "genera", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "author", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "helps", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "herbaria", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "acronym"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "higher_order_taxa", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "german_name", limit: 255
    t.integer "position"
    t.string "ancestry"
    t.index ["ancestry"], name: "index_higher_order_taxa_on_ancestry"
  end

  create_table "higher_order_taxa_markers", id: false, force: :cascade do |t|
    t.integer "higher_order_taxon_id"
    t.integer "marker_id"
  end

  create_table "higher_order_taxa_projects", id: false, force: :cascade do |t|
    t.integer "higher_order_taxon_id"
    t.integer "project_id"
  end

  create_table "homes", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.bigint "main_logo_id"
    t.index ["main_logo_id"], name: "index_homes_on_main_logo_id"
  end

  create_table "individual_searches", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "has_taxon"
    t.integer "has_problematic_location"
    t.integer "has_issue"
    t.string "specimen_id"
    t.string "DNA_bank_id"
    t.string "taxon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.integer "user_id"
    t.string "herbarium"
    t.index ["project_id"], name: "index_individual_searches_on_project_id"
    t.index ["user_id"], name: "index_individual_searches_on_user_id"
  end

  create_table "individuals", id: :serial, force: :cascade do |t|
    t.string "specimen_id", limit: 255
    t.string "DNA_bank_id", limit: 255
    t.string "collector", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "silica_gel"
    t.date "collected"
    t.integer "species_id"
    t.string "herbarium_code", limit: 255
    t.string "country", limit: 255
    t.string "state_province", limit: 255
    t.text "locality"
    t.string "latitude_original", limit: 255
    t.string "longitude_original", limit: 255
    t.string "elevation", limit: 255
    t.string "exposition", limit: 255
    t.text "habitat"
    t.string "substrate", limit: 255
    t.string "life_form", limit: 255
    t.string "collectors_field_number", limit: 255
    t.string "collection_date", limit: 255
    t.string "determination", limit: 255
    t.string "revision", limit: 255
    t.string "confirmation", limit: 255
    t.text "comments"
    t.decimal "latitude", precision: 15, scale: 6
    t.decimal "longitude", precision: 15, scale: 6
    t.boolean "has_issue"
    t.integer "herbarium_id"
    t.integer "tissue_id"
    t.bigint "taxon_id"
    t.index ["herbarium_id"], name: "index_individuals_on_herbarium_id"
    t.index ["taxon_id"], name: "index_individuals_on_taxon_id"
    t.index ["tissue_id"], name: "index_individuals_on_tissue_id"
  end

  create_table "individuals_projects", id: false, force: :cascade do |t|
    t.integer "individual_id"
    t.integer "project_id"
  end

  create_table "isolates", id: :serial, force: :cascade do |t|
    t.string "well_pos_plant_plate", limit: 255
    t.string "micronic_tube_id", limit: 255
    t.string "well_pos_micronic_plate", limit: 255
    t.decimal "concentration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tissue_id"
    t.integer "micronic_plate_id"
    t.integer "plant_plate_id"
    t.integer "individual_id"
    t.string "dna_bank_id", limit: 255
    t.string "lab_isolation_nr", limit: 255
    t.boolean "negative_control", default: false
    t.integer "lab_id_orig"
    t.integer "lab_id_copy"
    t.datetime "isolation_date"
    t.integer "micronic_plate_id_orig"
    t.integer "micronic_plate_id_copy"
    t.string "well_pos_micronic_plate_orig"
    t.string "well_pos_micronic_plate_copy"
    t.decimal "concentration_orig", precision: 15, scale: 2
    t.decimal "concentration_copy", precision: 15, scale: 2
    t.string "micronic_tube_id_orig"
    t.string "micronic_tube_id_copy"
    t.integer "user_id"
    t.text "comment_orig"
    t.text "comment_copy"
    t.string "display_name"
  end

  create_table "isolates_projects", id: false, force: :cascade do |t|
    t.integer "isolate_id"
    t.integer "project_id"
  end

  create_table "issues", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "primer_read_id"
    t.integer "contig_id"
    t.integer "ngs_run_id"
  end

  create_table "issues_projects", id: false, force: :cascade do |t|
    t.integer "issue_id"
    t.integer "project_id"
  end

  create_table "lab_racks", id: :serial, force: :cascade do |t|
    t.string "rackcode", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "rack_position"
    t.bigint "shelf_id"
    t.index ["shelf_id"], name: "index_lab_racks_on_shelf_id"
  end

  create_table "lab_racks_projects", id: false, force: :cascade do |t|
    t.integer "lab_rack_id", null: false
    t.integer "project_id", null: false
    t.index ["lab_rack_id", "project_id"], name: "index_lab_racks_projects_on_lab_rack_id_and_project_id"
  end

  create_table "labs", id: :serial, force: :cascade do |t|
    t.string "labcode", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labs_projects", id: false, force: :cascade do |t|
    t.integer "lab_id"
    t.integer "project_id"
  end

  create_table "logos", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.boolean "main", default: true
    t.bigint "home_id"
    t.boolean "display", default: true
    t.index ["home_id"], name: "index_logos_on_home_id"
  end

  create_table "marker_sequence_searches", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "verified"
    t.string "taxon"
    t.string "specimen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "title"
    t.string "marker"
    t.integer "min_length"
    t.integer "max_length"
    t.integer "project_id"
    t.boolean "has_taxon"
    t.integer "has_warnings"
    t.date "min_age"
    t.date "max_age"
    t.date "min_update"
    t.date "max_update"
    t.string "verified_by"
    t.integer "mislabel_analysis_id"
    t.boolean "no_isolate"
    t.index ["mislabel_analysis_id"], name: "index_marker_sequence_searches_on_mislabel_analysis_id"
    t.index ["project_id"], name: "index_marker_sequence_searches_on_project_id"
  end

  create_table "marker_sequences", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "genbank", limit: 255
    t.text "sequence"
    t.integer "isolate_id"
    t.integer "marker_id"
    t.string "reference"
  end

  create_table "marker_sequences_mislabel_analyses", id: false, force: :cascade do |t|
    t.integer "marker_sequence_id", null: false
    t.integer "mislabel_analysis_id", null: false
    t.index ["marker_sequence_id", "mislabel_analysis_id"], name: "index_marker_sequences_mislabel_analyses"
  end

  create_table "marker_sequences_projects", id: false, force: :cascade do |t|
    t.integer "marker_sequence_id", null: false
    t.integer "project_id", null: false
    t.index ["marker_sequence_id", "project_id"], name: "index_marker_sequences_projects"
  end

  create_table "markers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "expected_reads", default: 1
    t.string "alt_name"
  end

  create_table "markers_projects", id: false, force: :cascade do |t|
    t.integer "marker_id", null: false
    t.integer "project_id", null: false
    t.index ["marker_id", "project_id"], name: "index_markers_projects_on_marker_id_and_project_id"
  end

  create_table "micronic_plates", id: :serial, force: :cascade do |t|
    t.string "micronic_plate_id", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "location_in_rack", limit: 255
    t.integer "lab_rack_id"
  end

  create_table "micronic_plates_projects", id: false, force: :cascade do |t|
    t.integer "micronic_plate_id", null: false
    t.integer "project_id", null: false
    t.index ["micronic_plate_id", "project_id"], name: "index_micronic_plates_projects"
  end

  create_table "mislabel_analyses", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "automatic", default: false
    t.integer "marker_id"
    t.integer "total_seq_number"
    t.index ["marker_id"], name: "index_mislabel_analyses_on_marker_id"
  end

  create_table "mislabels", id: :serial, force: :cascade do |t|
    t.string "level"
    t.decimal "confidence"
    t.string "proposed_label"
    t.string "proposed_path"
    t.string "path_confidence"
    t.integer "mislabel_analysis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "marker_sequence_id"
    t.boolean "solved", default: false
    t.integer "solved_by"
    t.datetime "solved_at"
    t.index ["marker_sequence_id"], name: "index_mislabels_on_marker_sequence_id"
    t.index ["mislabel_analysis_id"], name: "index_mislabels_on_mislabel_analysis_id"
  end

  create_table "news", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "body"
    t.datetime "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ngs_results", id: :serial, force: :cascade do |t|
    t.integer "isolate_id"
    t.integer "marker_id"
    t.integer "ngs_run_id"
    t.integer "hq_sequences"
    t.integer "incomplete_sequences"
    t.integer "cluster_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_sequences"
    t.index ["isolate_id"], name: "index_ngs_results_on_isolate_id"
    t.index ["marker_id"], name: "index_ngs_results_on_marker_id"
    t.index ["ngs_run_id"], name: "index_ngs_results_on_ngs_run_id"
  end

  create_table "ngs_runs", id: :serial, force: :cascade do |t|
    t.integer "quality_threshold", default: 25
    t.integer "tag_mismatches", default: 2
    t.decimal "primer_mismatches", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
    t.integer "higher_order_taxon_id"
    t.string "set_tag_map_file_name"
    t.string "set_tag_map_content_type"
    t.integer "set_tag_map_file_size"
    t.datetime "set_tag_map_updated_at"
    t.integer "isolate_id"
    t.string "name"
    t.integer "sequences_pre"
    t.integer "sequences_filtered"
    t.integer "sequences_high_qual"
    t.integer "sequences_one_primer"
    t.string "results_file_name"
    t.string "results_content_type"
    t.integer "results_file_size"
    t.datetime "results_updated_at"
    t.integer "sequences_short"
    t.string "fastq_location"
    t.boolean "analysis_requested", default: false
    t.boolean "analysis_started", default: false
    t.bigint "taxon_id"
    t.index ["higher_order_taxon_id"], name: "index_ngs_runs_on_higher_order_taxon_id"
    t.index ["isolate_id"], name: "index_ngs_runs_on_isolate_id"
    t.index ["taxon_id"], name: "index_ngs_runs_on_taxon_id"
  end

  create_table "ngs_runs_projects", id: false, force: :cascade do |t|
    t.integer "ngs_run_id", null: false
    t.integer "project_id", null: false
    t.index ["ngs_run_id", "project_id"], name: "index_ngs_runs_projects_on_ngs_run_id_and_project_id"
  end

  create_table "oders", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "author", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "author", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "higher_order_taxon_id"
    t.integer "taxonomic_class_id"
  end

  create_table "orders_projects", id: false, force: :cascade do |t|
    t.integer "order_id"
    t.integer "project_id"
  end

  create_table "partial_cons", id: :serial, force: :cascade do |t|
    t.text "sequence"
    t.text "aligned_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "contig_id"
    t.integer "aligned_qualities", array: true
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.integer "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "plant_plates", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "lab_rack_id"
    t.index ["lab_rack_id"], name: "index_plant_plates_on_lab_rack_id"
  end

  create_table "plant_plates_projects", id: false, force: :cascade do |t|
    t.integer "plant_plate_id", null: false
    t.integer "project_id", null: false
    t.index ["plant_plate_id", "project_id"], name: "index_plant_plates_projects_on_plant_plate_id_and_project_id"
  end

  create_table "primer_pos_on_genomes", id: :serial, force: :cascade do |t|
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "primer_id"
    t.integer "species_id"
    t.index ["primer_id"], name: "index_primer_pos_on_genomes_on_primer_id"
    t.index ["species_id"], name: "index_primer_pos_on_genomes_on_species_id"
  end

  create_table "primer_reads", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "sequence"
    t.string "pherogram_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "chromatogram_file_name", limit: 255
    t.string "chromatogram_content_type", limit: 255
    t.integer "chromatogram_file_size"
    t.datetime "chromatogram_updated_at"
    t.integer "primer_id"
    t.integer "isolate_id"
    t.integer "contig_id"
    t.integer "trimmedReadEnd"
    t.integer "trimmedReadStart"
    t.integer "qualities", array: true
    t.boolean "reverse"
    t.text "aligned_seq"
    t.boolean "used_for_con"
    t.text "quality_string"
    t.integer "position"
    t.boolean "assembled"
    t.integer "partial_con_id"
    t.integer "aligned_qualities", array: true
    t.integer "window_size", default: 10
    t.integer "count_in_window", default: 8
    t.integer "min_quality_score", default: 30
    t.integer "atrace", array: true
    t.integer "ctrace", array: true
    t.integer "gtrace", array: true
    t.integer "ttrace", array: true
    t.integer "peak_indices", array: true
    t.boolean "processed", default: false
    t.integer "base_count"
    t.string "comment"
    t.boolean "overwritten", default: false
    t.integer "aligned_peak_indices", array: true
    t.string "chromatogram_fingerprint"
  end

  create_table "primer_reads_projects", id: false, force: :cascade do |t|
    t.integer "primer_read_id"
    t.integer "project_id"
  end

  create_table "primers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "sequence", limit: 255
    t.boolean "reverse"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "notes"
    t.integer "marker_id"
    t.string "labcode", limit: 255
    t.string "author", limit: 255
    t.string "alt_name", limit: 255
    t.string "target_group", limit: 255
    t.string "tm", limit: 255
    t.integer "position"
  end

  create_table "primers_projects", id: false, force: :cascade do |t|
    t.integer "primer_id", null: false
    t.integer "project_id", null: false
    t.index ["primer_id", "project_id"], name: "index_primers_projects_on_primer_id_and_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.datetime "start"
    t.datetime "due"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_shelves", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "shelf_id", null: false
    t.index ["project_id", "shelf_id"], name: "index_projects_shelves_on_project_id_and_shelf_id"
  end

  create_table "projects_species", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "species_id"
  end

  create_table "projects_tag_primer_maps", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "tag_primer_map_id", null: false
    t.index ["project_id", "tag_primer_map_id"], name: "index_projects_tag_primer_maps"
  end

  create_table "projects_taxa", id: false, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "taxon_id", null: false
    t.index ["project_id", "taxon_id"], name: "index_projects_taxa_on_project_id_and_taxon_id"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "responsibilities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "responsibilities_users", id: false, force: :cascade do |t|
    t.integer "responsibility_id", null: false
    t.integer "user_id", null: false
    t.index ["responsibility_id", "user_id"], name: "index_responsibilities_users_on_responsibility_id_and_user_id"
  end

  create_table "shelves", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "freezer_id"
    t.index ["freezer_id"], name: "index_shelves_on_freezer_id"
  end

  create_table "species", id: :serial, force: :cascade do |t|
    t.string "author", limit: 255
    t.string "genus_name", limit: 255
    t.string "species_epithet", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "family_id"
    t.string "infraspecific", limit: 255
    t.text "comment"
    t.string "german_name", limit: 255
    t.string "author_infra", limit: 255
    t.string "synonym", limit: 255
    t.string "composed_name", limit: 255
    t.string "species_component"
  end

  create_table "species_exporters", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "species_export_file_name"
    t.string "species_export_content_type"
    t.integer "species_export_file_size"
    t.datetime "species_export_updated_at"
  end

  create_table "specimen_exporters", id: :serial, force: :cascade do |t|
    t.string "specimen_export_file_name"
    t.string "specimen_export_content_type"
    t.integer "specimen_export_file_size"
    t.datetime "specimen_export_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subdivisions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "german_name"
    t.integer "division_id"
    t.index ["division_id"], name: "index_subdivisions_on_division_id"
  end

  create_table "tag_primer_maps", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ngs_run_id"
    t.string "tag_primer_map_file_name"
    t.string "tag_primer_map_content_type"
    t.integer "tag_primer_map_file_size"
    t.datetime "tag_primer_map_updated_at"
    t.string "name"
    t.string "tag"
    t.index ["ngs_run_id"], name: "index_tag_primer_maps_on_ngs_run_id"
  end

  create_table "taxa", force: :cascade do |t|
    t.string "scientific_name"
    t.string "common_name"
    t.string "position"
    t.string "synonym"
    t.string "author"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.integer "taxonomic_rank"
    t.integer "ancestry_depth", default: 0
    t.integer "children_count", default: 0
    t.integer "descendants_count", default: 0
    t.index ["ancestry"], name: "index_taxa_on_ancestry"
  end

  create_table "taxonomic_classes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subdivision_id"
    t.string "german_name"
  end

  create_table "tissues", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "txt_uploaders", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uploaded_file_file_name"
    t.string "uploaded_file_content_type"
    t.integer "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.integer "lab_id"
    t.integer "role"
    t.integer "default_project_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contig_searches", "projects"
  add_foreign_key "homes", "logos", column: "main_logo_id"
  add_foreign_key "individual_searches", "projects"
  add_foreign_key "individual_searches", "users"
  add_foreign_key "individuals", "herbaria"
  add_foreign_key "individuals", "taxa"
  add_foreign_key "individuals", "tissues"
  add_foreign_key "lab_racks", "shelves"
  add_foreign_key "marker_sequence_searches", "mislabel_analyses"
  add_foreign_key "marker_sequence_searches", "projects"
  add_foreign_key "mislabel_analyses", "markers"
  add_foreign_key "mislabels", "marker_sequences"
  add_foreign_key "ngs_runs", "higher_order_taxa"
  add_foreign_key "ngs_runs", "taxa"
  add_foreign_key "plant_plates", "lab_racks"
  add_foreign_key "primer_pos_on_genomes", "primers"
  add_foreign_key "primer_pos_on_genomes", "species"
  add_foreign_key "shelves", "freezers"
  add_foreign_key "subdivisions", "divisions"
end
