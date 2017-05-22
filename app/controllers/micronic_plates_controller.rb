class MicronicPlatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_micronic_plate, only: [:show, :edit, :update, :destroy]

  # GET /micronic_plates
  # GET /micronic_plates.json
  def index
    respond_to do |format|
      format.html
      format.json { render json:  MicronicPlateDatatable.new(view_context)}
    end
  end

  # GET /micronic_plates/1
  # GET /micronic_plates/1.json
  def show
  end

  # GET /micronic_plates/new
  def new
    @micronic_plate = MicronicPlate.new
  end

  # GET /micronic_plates/1/edit
  def edit
  end

  # POST /micronic_plates
  # POST /micronic_plates.json
  def create
    @micronic_plate = MicronicPlate.new(micronic_plate_params)

    respond_to do |format|
      if @micronic_plate.save
        format.html { redirect_to micronic_plates_path, notice: 'Micronic plate was successfully created.' }
        format.json { render :show, status: :created, location: @micronic_plate }
      else
        format.html { render :new }
        format.json { render json: @micronic_plate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /micronic_plates/1
  # PATCH/PUT /micronic_plates/1.json
  def update
    respond_to do |format|
      if @micronic_plate.update(micronic_plate_params)
        format.html { redirect_to micronic_plates_path, notice: 'Micronic plate was successfully updated.' }
        format.json { render :show, status: :ok, location: @micronic_plate }
      else
        format.html { render :edit }
        format.json { render json: @micronic_plate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /micronic_plates/1
  # DELETE /micronic_plates/1.json
  def destroy
    @micronic_plate.destroy
    respond_to do |format|
      format.html { redirect_to micronic_plates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_micronic_plate
      @micronic_plate = MicronicPlate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def micronic_plate_params
      params.require(:micronic_plate).permit(:location_in_rack, :micronic_plate_id, :name)
    end
end
