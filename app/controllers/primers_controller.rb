class PrimersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_primer, only: [:show, :edit, :update, :destroy]

  # GET /primers
  # GET /primers.json
  def index
    @primers = Primer.includes(:marker).all
  end

  def import
    # Species.import(params[:file])

    file = params[:file]

    #todo if needed, add logic to distinguish between xls / xlsx / error etc here -> mv from model.
    Primer.import(file.path) # when adding delayed_job here: jetzt wird nur string gespeichert for delayed_job yml representation in ActiveRecord, zuvor ganzes File!
    redirect_to primers_path, notice: "Imported."
  end

  # GET /primers/1
  # GET /primers/1.json
  def show
  end

  # GET /primers/new
  def new
    @primer = Primer.new
  end

  # GET /primers/1/edit
  def edit
  end

  # POST /primers
  # POST /primers.json
  def create
    @primer = Primer.new(primer_params)

    respond_to do |format|
      if @primer.save
        format.html { redirect_to primers_path, notice: 'Primer was successfully created.' }
        format.json { render :show, status: :created, location: @primer }
      else
        format.html { render :new }
        format.json { render json: @primer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /primers/1
  # PATCH/PUT /primers/1.json
  def update
    respond_to do |format|
      if @primer.update(primer_params)
        format.html { redirect_to primers_path, notice: 'Primer was successfully updated.' }
        format.json { render :show, status: :ok, location: @primer }
      else
        format.html { render :edit }
        format.json { render json: @primer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /primers/1
  # DELETE /primers/1.json
  def destroy
    @primer.destroy
    respond_to do |format|
      format.html { redirect_to primers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_primer
      @primer = Primer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def primer_params
      params.require(:primer).permit(:alt_name, :position, :file, :name, :sequence, :reverse, :marker_id)
    end
end
