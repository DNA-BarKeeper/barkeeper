class GensController < ApplicationController
  load_and_authorize_resource

  before_action :set_gen, only: [:show, :edit, :update, :destroy]

  # GET /gens
  # GET /gens.json
  def index
    @gens = Gen.search(params[:search]).order("name").page(params[:page]).per_page(2)
  end

  # GET /gens/1
  # GET /gens/1.json
  def show
  end

  # GET /gens/new
  def new
    @gen = Gen.new
  end

  # GET /gens/1/edit
  def edit
  end

  # POST /gens
  # POST /gens.json
  def create
    @gen = Gen.new(gen_params)

    respond_to do |format|
      if @gen.save
        format.html { redirect_to @gen, notice: 'Gen was successfully created.' }
        format.json { render :show, status: :created, location: @gen }
      else
        format.html { render :new }
        format.json { render json: @gen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gens/1
  # PATCH/PUT /gens/1.json
  def update
    respond_to do |format|
      if @gen.update(gen_params)
        format.html { redirect_to @gen, notice: 'Gen was successfully updated.' }
        format.json { render :show, status: :ok, location: @gen }
      else
        format.html { render :edit }
        format.json { render json: @gen.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gens/1
  # DELETE /gens/1.json
  def destroy
    @gen.destroy
    respond_to do |format|
      format.html { redirect_to gens_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gen
      @gen = Gen.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gen_params
      params.require(:gen).permit(:name, :author, :family_id, :family_name, :page, :search)
    end
end
