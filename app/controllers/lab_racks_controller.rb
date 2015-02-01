class LabRacksController < ApplicationController

  before_filter :authenticate_user!

  before_action :set_lab_rack, only: [:show, :edit, :update, :destroy]

  # GET /lab_racks
  # GET /lab_racks.json
  def index
    @lab_racks = LabRack.all
  end

  # GET /lab_racks/1
  # GET /lab_racks/1.json
  def show
  end

  # GET /lab_racks/new
  def new
    @lab_rack = LabRack.new
  end

  # GET /lab_racks/1/edit
  def edit
  end

  # POST /lab_racks
  # POST /lab_racks.json
  def create
    @lab_rack = LabRack.new(lab_rack_params)

    respond_to do |format|
      if @lab_rack.save
        format.html { redirect_to @lab_rack, notice: 'Lab rack was successfully created.' }
        format.json { render :show, status: :created, location: @lab_rack }
      else
        format.html { render :new }
        format.json { render json: @lab_rack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lab_racks/1
  # PATCH/PUT /lab_racks/1.json
  def update
    respond_to do |format|
      if @lab_rack.update(lab_rack_params)
        format.html { redirect_to @lab_rack, notice: 'Lab rack was successfully updated.' }
        format.json { render :show, status: :ok, location: @lab_rack }
      else
        format.html { render :edit }
        format.json { render json: @lab_rack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lab_racks/1
  # DELETE /lab_racks/1.json
  def destroy
    @lab_rack.destroy
    respond_to do |format|
      format.html { redirect_to lab_racks_url, notice: 'Lab rack was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lab_rack
      @lab_rack = LabRack.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lab_rack_params
      params.require(:lab_rack).permit(:rackcode, :freezer_id)
    end
end
