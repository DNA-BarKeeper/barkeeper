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

ActiveRecord::Schema.define(version: 20170619101312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "alignments", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "URL",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contig_pde_uploaders", force: :cascade do |t|
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "contigs", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.text     "consensus"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "marker_sequence_id"
    t.integer  "isolate_id"
    t.integer  "marker_id"
    t.boolean  "assembled"
    t.integer  "overlaps"
    t.text     "partial_cons1"
    t.text     "partial_cons2"
    t.boolean  "assembly_tried"
    t.string   "aligned_cons",             limit: 255
    t.text     "pde"
    t.text     "fas"
    t.boolean  "verified",                             default: false
    t.integer  "verified_by"
    t.datetime "verified_at"
    t.string   "comment"
    t.boolean  "imported",                             default: false
    t.integer  "partial_cons_count"
    t.integer  "overlap_length",                       default: 15
    t.integer  "allowed_mismatch_percent",             default: 5
  end

  create_table "contigs_projects", id: false, force: :cascade do |t|
    t.integer "contig_id"
    t.integer "project_id"
  end

  create_table "copies", force: :cascade do |t|
    t.string   "well_pos_plant_plate"
    t.integer  "lab_nr"
    t.integer  "micronic_tube_id"
    t.string   "well_pos_micronic_plate"
    t.decimal  "concentration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "divisions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "families", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "author",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
  end

  create_table "families_projects", id: false, force: :cascade do |t|
    t.integer "family_id"
    t.integer "project_id"
  end

  create_table "freezers", force: :cascade do |t|
    t.string   "freezercode", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lab_id"
  end

  create_table "genera", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "author",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "helps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "higher_order_taxa", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "german_name", limit: 255
    t.integer  "position"
  end

  create_table "higher_order_taxa_markers", id: false, force: :cascade do |t|
    t.integer "higher_order_taxon_id"
    t.integer "marker_id"
  end

  create_table "higher_order_taxa_projects", id: false, force: :cascade do |t|
    t.integer "higher_order_taxon_id"
    t.integer "project_id"
  end

  create_table "individuals", force: :cascade do |t|
    t.string   "specimen_id",        limit: 255
    t.string   "DNA_bank_id",        limit: 255
    t.string   "collector",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "silica_gel"
    t.date     "collected"
    t.integer  "species_id"
    t.string   "herbarium",          limit: 255
    t.string   "voucher",            limit: 255
    t.string   "country",            limit: 255
    t.string   "state_province",     limit: 255
    t.text     "locality"
    t.string   "latitude_original",  limit: 255
    t.string   "longitude_original", limit: 255
    t.string   "elevation",          limit: 255
    t.string   "exposition",         limit: 255
    t.text     "habitat"
    t.string   "substrate",          limit: 255
    t.string   "life_form",          limit: 255
    t.string   "collection_nr",      limit: 255
    t.string   "collection_date",    limit: 255
    t.string   "determination",      limit: 255
    t.string   "revision",           limit: 255
    t.string   "confirmation",       limit: 255
    t.text     "comments"
    t.decimal  "latitude"
    t.decimal  "longitude"
  end

  create_table "individuals_projects", id: false, force: :cascade do |t|
    t.integer "individual_id"
    t.integer "project_id"
  end

  create_table "isolates", force: :cascade do |t|
    t.string   "well_pos_plant_plate",         limit: 255
    t.string   "micronic_tube_id",             limit: 255
    t.string   "well_pos_micronic_plate",      limit: 255
    t.decimal  "concentration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "isCopy"
    t.integer  "tissue_id"
    t.integer  "micronic_plate_id"
    t.integer  "plant_plate_id"
    t.integer  "individual_id"
    t.string   "dna_bank_id",                  limit: 255
    t.string   "lab_nr",                       limit: 255
    t.boolean  "negative_control",                                                  default: false
    t.integer  "lab_id_orig"
    t.integer  "lab_id_copy"
    t.datetime "isolation_date"
    t.integer  "micronic_plate_id_orig"
    t.integer  "micronic_plate_id_copy"
    t.string   "well_pos_micronic_plate_orig"
    t.string   "well_pos_micronic_plate_copy"
    t.decimal  "concentration_orig",                       precision: 15, scale: 2
    t.decimal  "concentration_copy",                       precision: 15, scale: 2
    t.string   "micronic_tube_id_orig"
    t.string   "micronic_tube_id_copy"
    t.integer  "user_id"
    t.text     "comment_orig"
    t.text     "comment_copy"
  end

  create_table "isolates_projects", id: false, force: :cascade do |t|
    t.integer "isolate_id"
    t.integer "project_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "primer_read_id"
    t.integer  "contig_id"
  end

  create_table "issues_projects", id: false, force: :cascade do |t|
    t.integer "issue_id"
    t.integer "project_id"
  end

  create_table "lab_racks", force: :cascade do |t|
    t.string   "rackcode",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "freezer_id"
    t.string   "rack_position"
    t.string   "shelf"
  end

  create_table "labs", force: :cascade do |t|
    t.string   "labcode",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labs_projects", id: false, force: :cascade do |t|
    t.integer "lab_id"
    t.integer "project_id"
  end

  create_table "marker_sequences", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "genbank",    limit: 255
    t.text     "sequence"
    t.integer  "isolate_id"
    t.integer  "marker_id"
  end

  create_table "markers", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expected_reads"
    t.boolean  "is_gbol"
    t.string   "alt_name"
  end

  create_table "micronic_plates", force: :cascade do |t|
    t.string   "micronic_plate_id", limit: 255
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_in_rack",  limit: 255
    t.integer  "lab_rack_id"
  end

  create_table "news", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "body"
    t.datetime "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oders", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "author",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "author",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "higher_order_taxon_id"
    t.integer  "taxonomic_class_id"
  end

  create_table "orders_projects", id: false, force: :cascade do |t|
    t.integer "order_id"
    t.integer "project_id"
  end

  create_table "partial_cons", force: :cascade do |t|
    t.text     "sequence"
    t.text     "aligned_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contig_id"
    t.integer  "aligned_qualities", array: true
  end

  create_table "plant_plates", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "how_many"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_in_rack", limit: 255
  end

  create_table "primer_pos_on_genomes", force: :cascade do |t|
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "primer_reads", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.text     "sequence"
    t.string   "pherogram_url",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chromatogram_file_name",    limit: 255
    t.string   "chromatogram_content_type", limit: 255
    t.integer  "chromatogram_file_size"
    t.datetime "chromatogram_updated_at"
    t.integer  "primer_id"
    t.integer  "isolate_id"
    t.integer  "contig_id"
    t.integer  "trimmedReadEnd"
    t.integer  "trimmedReadStart"
    t.integer  "qualities",                                             array: true
    t.boolean  "reverse"
    t.text     "aligned_seq"
    t.boolean  "used_for_con"
    t.text     "quality_string"
    t.integer  "position"
    t.boolean  "assembled"
    t.integer  "partial_con_id"
    t.integer  "aligned_qualities",                                     array: true
    t.integer  "window_size",                           default: 10
    t.integer  "count_in_window",                       default: 8
    t.integer  "min_quality_score",                     default: 30
    t.integer  "atrace",                                                array: true
    t.integer  "ctrace",                                                array: true
    t.integer  "gtrace",                                                array: true
    t.integer  "ttrace",                                                array: true
    t.integer  "peak_indices",                                          array: true
    t.boolean  "processed",                             default: false
    t.integer  "base_count"
    t.string   "comment"
    t.boolean  "overwritten",                           default: false
    t.integer  "aligned_peak_indices",                                  array: true
  end

  create_table "primer_reads_projects", id: false, force: :cascade do |t|
    t.integer "primer_read_id"
    t.integer "project_id"
  end

  create_table "primers", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "sequence",     limit: 255
    t.boolean  "reverse"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.integer  "marker_id"
    t.string   "labcode",      limit: 255
    t.string   "author",       limit: 255
    t.string   "alt_name",     limit: 255
    t.string   "target_group", limit: 255
    t.string   "tm",           limit: 255
    t.integer  "position"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.datetime "start"
    t.datetime "due"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_species", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "species_id"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "shelves", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "species", force: :cascade do |t|
    t.string   "author",            limit: 255
    t.string   "genus_name",        limit: 255
    t.string   "species_epithet",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "family_id"
    t.string   "infraspecific",     limit: 255
    t.text     "comment"
    t.string   "german_name",       limit: 255
    t.string   "author_infra",      limit: 255
    t.string   "synonym",           limit: 255
    t.string   "composed_name",     limit: 255
    t.string   "species_component"
  end

  create_table "species_xml_uploaders", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contig_id"
  end

  create_table "subdivisions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "position"
    t.string   "german_name"
  end

  create_table "taxonomic_classes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "subdivision_id"
    t.string   "german_name"
  end

  create_table "tissues", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "txt_uploaders", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "xml_uploaders", force: :cascade do |t|
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
