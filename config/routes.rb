GBOLapp::Application.routes.draw do

  root :to => "home#about"

  match 'help',    to: 'home#help',    via: 'get'
  match 'about',   to: 'home#about',   via: 'get'
  match 'impressum',   to: 'home#impressum',   via: 'get'
  match 'contact', to: 'home#contact', via: 'get'
  match 'overview', to: 'home#overview', via: 'get'

  get 'specimens_xls', action: :xls, controller: 'individuals'
  get 'specimens_create_xls', action: :create_xls, controller: 'individuals'
  get 'species_xls', action: :xls, controller: 'species'
  get 'species_create_xls', action: :create_xls, controller: 'species'
  get 'caryo_contigs_zip', action: :zip, controller: 'contigs'
  get 'create_caryo_contigs_zip', action: :upload_caryo_matK_contigs, controller: 'contigs'
  get 'analysis_output', action: :analysis_output, controller: 'contigs'
  get 'reads_without_contigs', action: :reads_without_contigs, controller: 'primer_reads'
  get 'specimens_without_species', action: :specimens_without_species, controller: 'individuals'
  get 'problematic_location_data', action: :problematic_location_data, controller: 'individuals'

  get 'partial_cons/:id/:page/:width_in_bases', action: :show_page, controller: 'partial_cons', :defaults => { :format => 'json' }
  get 'partial_cons_pos/:id/:position/:width_in_bases', action: :show_position, controller: 'partial_cons', :defaults => { :format => 'json' }

  get 'primer_reads/:id/edit/:pos', action: :go_to_pos, controller: 'primer_reads'

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
      get 'pde_all'
      get 'duplicates'
      post :change_via_script
      post :compare_contigs
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

  resources :individuals

  resources :issues

  resources :higher_order_taxons do
    member do
      get 'show_species'
    end
  end

  resources :species do
    collection do
      post :import
      get :filter
      get :get_mar
      get :get_bry
      get :get_ant
    end
    member do
      get 'show_individuals'
    end
  end

  resources :primer_pos_on_genomes

  resources :alignments

  resources :projects

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

  resources :individuals do
    collection do
      get :filter
      # get 'create_xls'
      # get 'xls'
      get :problematic_specimens
    end
  end

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
  end

  resources :families do
    collection do
      get 'filter'
    end
    member do
      get 'show_species'
    end
  end


  #hack: avoid malicious users to directly type in the sign-up route
  #later: use authorization system to
  devise_scope :user do
    get "/users/sign_up",  :to => "home#about"
  end

  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :users do
    member do
      get 'edit'
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end