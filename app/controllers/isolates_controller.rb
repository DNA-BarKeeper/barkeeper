class IsolatesController < ApplicationController
  before_filter :authenticate_user!

  before_action :set_copy, only: [:show, :edit, :update, :destroy]

  # GET /copies
  # GET /copies.json
  def index
    respond_to do |format|
      format.html
      format.json { render json:  IsolateDatatable.new(view_context)}
    end
  end

  def prefilter
   #TODO read parameter "query" and restrict to those
    if params[:query]
      # @isolates=Isolate.order(:lab_nr).where...
    end
  end


  def filter
    @isolates = Isolate.include(:individual => :species).order(:lab_nr).where("lab_nr ILIKE ?", "%#{params[:term]}%")
    render json: @isolates.map(&:lab_nr)
  end

  def import

    file = params[:file]

    #todo if needed, add logic to distinguish between xls / xlsx / error etc here -> mv from model

    # Isolate.correct_coordinates(file.path)
    Isolate.import(file.path)
    # Isolate.import_dnabank_info(file.path)
    redirect_to isolates_path, notice: "Imported."
  end


  # GET /copies/1
  # GET /copies/1.json
  def show
  end

  # GET /copies/new
  def new
    @isolate = Isolate.new
  end

  # GET /copies/1/edit
  def edit
  end

  # POST /copies
  # POST /copies.json
  def create
    @isolate = Isolate.new(copy_params)

    respond_to do |format|
      if @isolate.save
        format.html { redirect_to isolates_path, notice: 'Isolate was successfully created.' }
        format.json { render :show, status: :created, location: @isolate }
      else
        format.html { render :new }
        format.json { render json: @isolate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /copies/1
  # PATCH/PUT /copies/1.json
  def update
    respond_to do |format|
      if @isolate.update(copy_params)
        format.html { redirect_to isolates_path, notice: 'Isolate was successfully updated.' }
        format.json { render :show, status: :ok, location: @isolate }
      else
        format.html { render :edit }
        format.json { render json: @isolate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /copies/1
  # DELETE /copies/1.json
  def destroy
    @isolate.destroy
    respond_to do |format|
      format.html { redirect_to isolates_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_copy
    @isolate = Isolate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def copy_params
    params.require(:isolate).permit(:well_pos_plant_plate, :lab_nr, :micronic_tube_id, :well_pos_micronic_plate, :concentration,
                                    :tissue_id, :micronic_plate_id, :plant_plate_id, :term,
                                    :file,
                                    :individual_name,
                                    :query)
  end
end
