class FreezersController < ApplicationController
  load_and_authorize_resource

  before_action :set_freezer, only: [:show, :edit, :update, :destroy]

  # GET /freezers
  # GET /freezers.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: FreezerDatatable.new(view_context, current_user.default_project_id) }
    end
  end

  # GET /freezers/1
  # GET /freezers/1.json
  def show
  end

  # GET /freezers/new
  def new
    @freezer = Freezer.new
  end

  # GET /freezers/1/edit
  def edit
  end

  # POST /freezers
  # POST /freezers.json
  def create
    @freezer = Freezer.new(freezer_params)

    respond_to do |format|
      if @freezer.save
        format.html { redirect_to freezers_path, notice: 'Freezer was successfully created.' }
        format.json { render :show, status: :created, location: @freezer }
      else
        format.html { render :new }
        format.json { render json: @freezer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /freezers/1
  # PATCH/PUT /freezers/1.json
  def update
    respond_to do |format|
      if @freezer.update(freezer_params)
        format.html { redirect_to freezers_path, notice: 'Freezer was successfully updated.' }
        format.json { render :show, status: :ok, location: @freezer }
      else
        format.html { render :edit }
        format.json { render json: @freezer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /freezers/1
  # DELETE /freezers/1.json
  def destroy
    @freezer.destroy
    respond_to do |format|
      format.html { redirect_to freezers_url, notice: 'Freezer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_freezer
    @freezer = Freezer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def freezer_params
    params.require(:freezer).permit(:freezercode, :lab_id)
  end
end
