# frozen_string_literal: true

# noinspection RubyArgCount
class SpeciesController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_species, only: %i[show edit update destroy]

  def create_xls
    SpeciesExport.perform_async(current_project_id)
    redirect_to species_index_path, notice: "Writing Excel file to S3 in background. May take a minute or so. Download from Species index page > 'Download last species export'."
  end

  def xls
    begin
      data = if Rails.env.development?
               File.read(SpeciesExporter.last.species_export.path)
             else
               File.read(SpeciesExporter.last.species_export.url)
             end

      send_data(data, filename: 'species_export.xls',
                      type: 'application/vnd.ms-excel',
                      disposition: 'attachment',
                      stream: 'true',
                      buffer_size: '4096')
    rescue Errno::ENOENT
      redirect_to @contig_search, notice: 'Please wait while the file is being written to the server.'
    end
  end

  # GET /species
  # GET /species.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: SpeciesDatatable.new(view_context, nil, nil, current_project_id) }
    end
  end

  def filter
    @species = Species.where('composed_name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).order(:composed_name).limit(100)
    size = Species.where('composed_name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).order(:composed_name).size

    if size > 100
      render json: @species.map(&:composed_name).push("and #{size} more...")
    else
      render json: @species.map(&:composed_name)
    end
  end

  def show_individuals
    respond_to do |format|
      format.html
      format.json { render json: IndividualDatatable.new(view_context, params[:id], current_project_id) }
    end
  end

  def import_stuttgart
    file = params[:file]
    Species.import_stuttgart(file, current_user.default_project_id) # When adding delayed_job here: jetzt wird nur string gespeichert for delayed_job yml representation in ActiveRecord, zuvor ganzes File!
    redirect_to species_index_path, notice: 'Imported.'
  end

  def import_berlin
    file = params[:file]
    Species.import_berlin(file, current_user.default_project_id)
    redirect_to species_index_path, notice: 'Imported.'
  end

  def import_gbolii
    file = params[:file]
    Species.import_gbolII(file, current_user.default_project_id)
    redirect_to species_index_path, notice: 'Imported.'
  end

  def get_mar
    ht = HigherOrderTaxon.find(4)
    collect_and_send_species(ht)
  end

  def get_bry
    ht = HigherOrderTaxon.find(9)
    collect_and_send_species(ht)
  end

  def get_ant
    ht = HigherOrderTaxon.find(8)
    collect_and_send_species(ht)
  end

  def collect_and_send_species(ht)
    str = ''

    @species = Species.joins(family: { order: :higher_order_taxon }).where(orders: { higher_order_taxon_id: ht.id }).in_project(current_project_id).each do |s|
      str += s.id.to_s + "\t" + s.name_for_display + "\n"
    end

    send_data(str, filename: "#{ht.name}.txt", type: 'application/txt')
  end

  # GET /species/1
  # GET /species/1.json
  def show; end

  # GET /species/new
  def new
    @species = Species.new
  end

  # GET /species/1/edit
  def edit; end

  # POST /species
  # POST /species.json
  def create
    @species = Species.new(species_params)
    @species.add_project(current_project_id)

    respond_to do |format|
      if @species.save
        @species.update(species_component: @species.get_species_component)
        @species.update(composed_name: @species.full_name)
        format.html { redirect_to species_index_path, notice: 'Species was successfully created.' }
        format.json { render :show, status: :created, location: @species }
      else
        format.html { render :new }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /species/1
  # PATCH/PUT /species/1.json
  def update
    respond_to do |format|
      if @species.update(species_params)
        @species.update(species_component: @species.get_species_component)
        @species.update(composed_name: @species.full_name)
        format.html do
          issue = Issue.create(title: "#{@species.name_for_display} updated by #{current_user.name}")
          issue.add_projects(@species.projects.pluck(:id))
          issue.save
          redirect_to species_index_path, notice: 'Species was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @species }
      else
        format.html { render :edit }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /species/1
  # DELETE /species/1.json
  def destroy
    @species.destroy
    respond_to do |format|
      format.html { redirect_to species_index_url, notice: 'Species was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_species
    @species = Species.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def species_params
    params.require(:species).permit(:term, :originalFileName, :file, :infraspecific, :comment, :author_infra, :family_name, :family_id,
                                    :author, :genus_name, :species_epithet, :composed_name, project_ids: [])
  end
end
