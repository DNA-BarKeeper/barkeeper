class IsolatesController < ApplicationController
  before_filter :authenticate_user!, :except => [:edit, :index, :filter]

  before_action :set_copy, only: [:show, :edit, :update, :destroy]

  # GET /copies
  # GET /copies.json
  def index
    respond_to do |format|
      format.html
      format.json { render json:  IsolateDatatable.new(view_context)}
    end
  end


  def duplicates

  end

  def no_specimen
    
  end


  def filter
    @isolates = Isolate.select('lab_nr, id').where('lab_nr ILIKE ?', "%#{params[:term]}%").order(:lab_nr)
    render json: @isolates.map(&:lab_nr)
  end

  def import

    file = params[:file]

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
    @isolate = Isolate.includes(:individual).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def copy_params
    params.require(:isolate).permit(:micronic_tube_id_copy, :micronic_tube_id_orig, :concentration_copy, :concentration_orig, :well_pos_micronic_plate_copy, :well_pos_micronic_plate_orig, :micronic_plate_id_copy,:micronic_plate_id_orig, :isolation_date, :lab_id_copy, :lab_id_orig, :user_id, :well_pos_plant_plate, :lab_nr, :micronic_tube_id, :well_pos_micronic_plate, :concentration,
                                    :tissue_id, :micronic_plate_id, :plant_plate_id, :term,
                                    :file,
                                    :individual_name,
                                    :query)
  end
end
