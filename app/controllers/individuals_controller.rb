class IndividualsController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_individual, :only => [:show, :edit, :update, :destroy]

  def specimens_without_species
  end

  def problematic_location_data
  end

  def index
    respond_to do |format|
      format.html
      format.json { render json: IndividualDatatable.new(view_context, nil, current_project_id) }
    end
  end

  def create_xls
    SpecimenExport.perform_async
    redirect_to individuals_path, notice: "Writing Excel file to S3 in background. May take a minute or so. Download from Specimens index page > 'Download last specimens export'."
  end

  def xls
    data = open("http:#{XmlUploader.last.uploaded_file.url}")
    send_data data.read, filename: 'specimens.xls', type: 'application/vnd.ms-excel', disposition: 'attachment', stream: 'true', buffer_size: '4096'
  end

  def problematic_specimens
    # Liste aller Bundesländer to check 'state_province' against:
    @states = %w(Baden-Württemberg Bayern Berlin Brandenburg Bremen Hamburg Hessen Mecklenburg-Vorpommern Niedersachsen Nordrhein-Westfalen Rheinland-Pfalz Saarland Sachsen Sachsen-Anhalt Schleswig-Holstein Thüringen)
    @individuals = []

    Individual.in_project(current_project_id).each do |i|
      if i.country == "Germany"
        @individuals.push(i) unless @states.include? i.state_province
      end
    end

  end

  def filter
    @individuals = Individual.where("individuals.specimen_id ilike ?", "%#{params[:term]}%").in_project(current_project_id).limit(100)
    size = Individual.where("individuals.specimen_id ilike ?", "%#{params[:term]}%").in_project(current_project_id).size

    if size > 100
      message = "and #{size} more..."
      render json: @individuals.map(&:specimen_id).push(message)
    else
      render json: @individuals.map(&:specimen_id)
    end
  end

  # GET /individuals/1
  # GET /individuals/1.json
  def show
  end

  # GET /individuals/new
  def new
    @individual = Individual.new
  end

  # GET /individuals/1/edit
  def edit
  end

  # POST /individuals
  # POST /individuals.json
  def create
    @individual = Individual.new(individual_params)
    @individual.add_project(current_project_id)

    respond_to do |format|
      if @individual.save
        format.html { redirect_to individuals_path, notice: 'Individual was successfully created.' }
        format.json { render :show, status: :created, location: @individual }
      else
        format.html { render :new }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /individuals/1
  # PATCH/PUT /individuals/1.json
  def update
    respond_to do |format|
      if @individual.update(individual_params)
        format.html { redirect_to individuals_path, notice: 'Individual was successfully updated.' }
        format.json { render :show, status: :ok, location: @individual }
      else
        format.html { render :edit }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /individuals/1
  # DELETE /individuals/1.json
  def destroy
    @individual.destroy
    respond_to do |format|
      format.html { redirect_to individuals_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_individual
    @individual = Individual.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def individual_params
    params.require(:individual).permit(:specimen_id,
                                       :DNA_bank_id,
                                       :collector,
                                       :specimen_id,
                                       :herbarium,
                                       :voucher,
                                       :country,
                                       :state_province,
                                       :locality,
                                       :latitude,
                                       :longitude,
                                       :latitude_original,
                                       :longitude_original,
                                       :elevation,
                                       :exposition,
                                       :habitat,
                                       :substrate,
                                       :life_form,
                                       :collection_nr,
                                       :collection_date,
                                       :determination,
                                       :revision,
                                       :confirmation,
                                       :comments,
                                       :species_id,
                                       :species_name,
                                       :project_ids => [])
  end
end