# frozen_string_literal: true

GBOLapp::Application.routes.draw do
  root to: 'homes#about'

  match 'about', to: 'homes#about', via: 'get'
  match 'impressum', to: 'homes#impressum', via: 'get'
  match 'privacy_policy', to: 'homes#privacy_policy', via: 'get'
  match 'overview', to: 'homes#overview', via: 'get'

  get 'overview_diagram/index'
  get 'overview_diagram/all_species', defaults: { format: 'json' }
  get 'overview_diagram/finished_species_trnlf', defaults: { format: 'json' }
  get 'overview_diagram/finished_species_its', defaults: { format: 'json' }
  get 'overview_diagram/finished_species_rpl16', defaults: { format: 'json' }
  get 'overview_diagram/finished_species_trnk_matk', defaults: { format: 'json' }

  get 'analysis_output', action: :analysis_output, controller: 'contigs'
  get 'reads_without_contigs', action: :reads_without_contigs, controller: 'primer_reads'

  get 'partial_cons/:id/:page/:width_in_bases', action: :show_page, controller: 'partial_cons', defaults: { format: 'json' }
  get 'partial_cons_pos/:id/:position/:width_in_bases', action: :show_position, controller: 'partial_cons', defaults: { format: 'json' }

  get 'primer_reads/:id/edit/:pos', action: :go_to_pos, controller: 'primer_reads'

  resources :homes

  resources :contig_searches do
    get :delete_all
    get :export_results_as_zip
    get :download_results
    get :export_as_pde
  end

  resources :marker_sequence_searches do
    get :export_as_fasta
    get :export_as_pde
  end

  resources :ngs_runs do
    collection do
      post :revised_tpm
    end

    member do
      get :analysis_results
      post :import
      post :start_analysis
    end
  end

  resources :clusters

  resources :individual_searches

  resources :herbaria

  resources :contigs do
    collection do
      get 'show_need_verify'
      get 'caryophyllales_need_verification'
      get 'caryophyllales_not_assembled'
      get 'caryophyllales_verified'
      get 'festuca_need_verification'
      get 'festuca_not_assembled'
      get 'festuca_verified'
      get 'filter'
      get 'assemble_all'
      get 'duplicates'
      post :import
      post :change_via_script
      post :compare_contigs # TODO: Marked for removal
      post :as_fasq
      get 'externally_verified'
    end

    member do
      get 'verify_next'
      get 'verify'
      get 'pde'
      get 'fasta'
      get 'fasta_trimmed'
      get 'fasta_raw'
      get 'overlap'
      get 'overlap_background'
    end
  end

  resources :individuals do
    collection do
      get :filter
      get :problematic_specimens
      get :create_xls
      get :xls
    end
  end

  resources :primer_reads do
    collection do
      post :import
      post :batch_create
      get 'duplicates'
    end

    member do
      get 'do_not_use_for_assembly'
      get 'use_for_assembly'
      get 'trim'
      get 'assign'
      get 'reverse'
      get 'restore'
      get 'fasta'
      post 'change_base'
      post 'change_left_clip'
      post 'change_right_clip'
    end
  end

  resources :txt_uploaders

  resources :issues

  resources :higher_order_taxa do
    collection do
      get 'hierarchy_tree', defaults: { format: 'json' }
    end

    member do
      get 'show_species'
    end
  end

  resources :species do
    collection do
      get :filter
      get :get_mar
      get :get_bry
      get :get_ant
      get :create_xls
      get :xls
      post :import_stuttgart
      post :import_berlin
      post :import_gbolii
    end

    member do
      get 'show_individuals'
    end
  end

  resources :primer_pos_on_genomes

  resources :projects do
    collection do
      get :search_taxa
      get :add_to_taxa
    end
  end

  resources :shelves

  resources :labs

  resources :freezers

  resources :lab_racks

  resources :marker_sequences do
    collection do
      get :filter
    end
  end

  resources :orders

  resources :tissues

  resources :statuses

  resources :primers do
    collection do
      post :import
    end
  end

  resources :plant_plates

  resources :micronic_plates

  resources :markers

  resources :isolates do
    collection do
      get 'filter'
      get 'duplicates'
      get 'no_specimen'
      post :import
    end
    member do
      get 'show_clusters'
    end
  end

  resources :mislabel_analyses do
    member do
      post :download_results
    end
  end

  resources :mislabels do
    member do
      get :solve
    end
  end

  resources :families do
    collection do
      get 'filter'
    end
    member do
      get 'show_species'
    end
  end

  resources :responsibilities

  # HACK: avoid malicious users to directly type in the sign-up route
  # later: use authorization system to
  devise_scope :user do
    get '/users/sign_up', to: 'homes#about'
  end

  devise_for :users, controllers: { registrations: 'registrations' }, path_names: { sign_in: 'login', sign_out: 'logout' }
  devise_scope :users do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end
  resources :users, controller: 'users' do
    member do
      get 'home'
    end
  end

  post 'create_user' => 'users#create', as: :create_user
  delete '/users/:id' => 'users#destroy', :as => :destroy_user

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
