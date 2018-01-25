class HigherOrderTaxonsController < ApplicationController
  load_and_authorize_resource

  before_action :set_higher_order_taxon, only: [:show, :edit, :update, :destroy]

  # GET /higher_order_taxons
  # GET /higher_order_taxons.json
  def index
    @higher_order_taxons = HigherOrderTaxon.order(:position).all
  end

  def show_species
    respond_to do |format|
          format.html
          format.json { render json: SpeciesDatatable.new(view_context, nil, params[:id]) }
        end
  end

  # GET /higher_order_taxons/1
  # GET /higher_order_taxons/1.json
  def show
  end

  # GET /higher_order_taxons/new
  def new
    @higher_order_taxon = HigherOrderTaxon.new
  end

  # GET /higher_order_taxons/1/edit
  def edit
  end

  # POST /higher_order_taxons
  # POST /higher_order_taxons.json
  def create
    @higher_order_taxon = HigherOrderTaxon.new(higher_order_taxon_params)

    respond_to do |format|
      if @higher_order_taxon.save
        format.html { redirect_to higher_order_taxons_path, notice: 'Higher order taxon was successfully created.' }
        format.json { render :show, status: :created, location: @higher_order_taxon }
      else
        format.html { render :new }
        format.json { render json: @higher_order_taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /higher_order_taxons/1
  # PATCH/PUT /higher_order_taxons/1.json
  def update
    respond_to do |format|
      if @higher_order_taxon.update(higher_order_taxon_params)
        format.html { redirect_to higher_order_taxons_path, notice: 'Higher order taxon was successfully updated.' }
        format.json { render :show, status: :ok, location: @higher_order_taxon }
      else
        format.html { render :edit }
        format.json { render json: @higher_order_taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /higher_order_taxons/1
  # DELETE /higher_order_taxons/1.json
  def destroy
    @higher_order_taxon.destroy
    respond_to do |format|
      format.html { redirect_to higher_order_taxons_url, notice: 'Higher order taxon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_higher_order_taxon
      @higher_order_taxon = HigherOrderTaxon.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def higher_order_taxon_params
      params.require(:higher_order_taxon).permit(:position, :name, :german_name,:marker_ids => [])
    end
end
