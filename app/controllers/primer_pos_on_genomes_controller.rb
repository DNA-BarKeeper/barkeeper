class PrimerPosOnGenomesController < ApplicationController

  before_filter :authenticate_user!

  before_action :set_primer_pos_on_genome, only: [:show, :edit, :update, :destroy]

  # GET /primer_pos_on_genomes
  # GET /primer_pos_on_genomes.json
  def index
    @primer_pos_on_genomes = PrimerPosOnGenome.all
  end

  # GET /primer_pos_on_genomes/1
  # GET /primer_pos_on_genomes/1.json
  def show
  end

  # GET /primer_pos_on_genomes/new
  def new
    @primer_pos_on_genome = PrimerPosOnGenome.new
  end

  # GET /primer_pos_on_genomes/1/edit
  def edit
  end

  # POST /primer_pos_on_genomes
  # POST /primer_pos_on_genomes.json
  def create
    @primer_pos_on_genome = PrimerPosOnGenome.new(primer_pos_on_genome_params)

    respond_to do |format|
      if @primer_pos_on_genome.save
        format.html { redirect_to @primer_pos_on_genome, notice: 'Primer pos on genome was successfully created.' }
        format.json { render :show, status: :created, location: @primer_pos_on_genome }
      else
        format.html { render :new }
        format.json { render json: @primer_pos_on_genome.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /primer_pos_on_genomes/1
  # PATCH/PUT /primer_pos_on_genomes/1.json
  def update
    respond_to do |format|
      if @primer_pos_on_genome.update(primer_pos_on_genome_params)
        format.html { redirect_to @primer_pos_on_genome, notice: 'Primer pos on genome was successfully updated.' }
        format.json { render :show, status: :ok, location: @primer_pos_on_genome }
      else
        format.html { render :edit }
        format.json { render json: @primer_pos_on_genome.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /primer_pos_on_genomes/1
  # DELETE /primer_pos_on_genomes/1.json
  def destroy
    @primer_pos_on_genome.destroy
    respond_to do |format|
      format.html { redirect_to primer_pos_on_genomes_url, notice: 'Primer pos on genome was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_primer_pos_on_genome
      @primer_pos_on_genome = PrimerPosOnGenome.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def primer_pos_on_genome_params
      params.require(:primer_pos_on_genome).permit(:note, :position)
    end
end
