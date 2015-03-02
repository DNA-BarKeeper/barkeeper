# noinspection RubyArgCount
class SpeciesController < ApplicationController

  before_filter :authenticate_user!, :except => [:edit, :index, :filter]

  before_action :set_species, only: [:show, :edit, :update, :destroy]

  # GET /species
  # GET /species.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: SpeciesDatatable.new(view_context) }
      format.csv { send_data @species.to_csv}
      format.xls
    end
  end

  def filter
    @species = Species.where('composed_name ILIKE ?', "%#{params[:term]}%").order(:composed_name)
    render json: @species.map(&:composed_name)
  end

  def import
    # Species.import(params[:file])

    file = params[:file]

    #todo if needed, add logic to distinguish between xls / xlsx / error etc here -> mv from model.
    Species.import(file.path) # when adding delayed_job here: jetzt wird nur string gespeichert for delayed_job yml representation in ActiveRecord, zuvor ganzes File!
    redirect_to species_index_path, notice: "Imported."
  end

  # GET /species/1
  # GET /species/1.json
  def show
  end

  # GET /species/new
  def new
    @species = Species.new
  end

  # GET /species/1/edit
  def edit
  end

  # POST /species
  # POST /species.json
  def create
    @species = Species.new(species_params)

    respond_to do |format|
      if @species.save
        @species.update(:species_component => @species.get_species_component)
        @species.update(:composed_name=>sp.full_name)
        format.html { redirect_to @species, notice: 'Species was successfully created.' }
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
        @species.update(:species_component => @species.get_species_component)
        @species.update(:composed_name=>sp.full_name)
        format.html { redirect_to species_index_path, notice: 'Species was successfully updated.' }
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
                                      :author, :genus_name, :species_epithet, :composed_name)
    end
end
