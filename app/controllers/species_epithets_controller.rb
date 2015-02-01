class SpeciesEpithetsController < ApplicationController
  before_action :set_species_epithet, only: [:show, :edit, :update, :destroy]

  # GET /species_epithets
  # GET /species_epithets.json
  def index
    @species_epithets = SpeciesEpithet.all
  end

  # GET /species_epithets/1
  # GET /species_epithets/1.json
  def show
  end

  # GET /species_epithets/new
  def new
    @species_epithet = SpeciesEpithet.new
  end

  # GET /species_epithets/1/edit
  def edit
  end

  # POST /species_epithets
  # POST /species_epithets.json
  def create
    @species_epithet = SpeciesEpithet.new(species_epithet_params)

    respond_to do |format|
      if @species_epithet.save
        format.html { redirect_to @species_epithet, notice: 'Species epithet was successfully created.' }
        format.json { render :show, status: :created, location: @species_epithet }
      else
        format.html { render :new }
        format.json { render json: @species_epithet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /species_epithets/1
  # PATCH/PUT /species_epithets/1.json
  def update
    respond_to do |format|
      if @species_epithet.update(species_epithet_params)
        format.html { redirect_to @species_epithet, notice: 'Species epithet was successfully updated.' }
        format.json { render :show, status: :ok, location: @species_epithet }
      else
        format.html { render :edit }
        format.json { render json: @species_epithet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /species_epithets/1
  # DELETE /species_epithets/1.json
  def destroy
    @species_epithet.destroy
    respond_to do |format|
      format.html { redirect_to species_epithets_url, notice: 'Species epithet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_species_epithet
      @species_epithet = SpeciesEpithet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def species_epithet_params
      params.require(:species_epithet).permit(:name)
    end
end
