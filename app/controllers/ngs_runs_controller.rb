class NgsRunsController < ApplicationController
  include ProjectConcern
  load_and_authorize_resource

  before_action :set_ngs_run, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: NgsRunDatatable.new(view_context, current_project_id) }
    end
  end

  def show
  end

  def new
    @ngs_run = NgsRun.new
  end

  def edit
  end

  def create
    @ngs_run = NgsRun.new(ngs_run_params)
    @ngs_run.add_project(current_project_id)

    respond_to do |format|
      if @ngs_run.save
        format.html { redirect_to ngs_runs_path, notice: 'NGS Run was successfully created.' }
        format.json { render :show, status: :created, location: @ngs_run }
      else
        format.html { render :new }
        format.json { render json: @ngs_run.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @ngs_run.update(ngs_run_params)
        format.html { redirect_to @ngs_run, notice: 'NGS Run was successfully updated.' }
        format.json { render :show, status: :ok, location: @ngs_run }
      else
        format.html { render :edit }
        format.json { render json: @ngs_run.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ngs_run.destroy
    respond_to do |format|
      format.html { redirect_to ngs_runs_url, notice: 'NGS Run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ngs_run
    @ngs_run = NgsRun.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ngs_run_params
    params.require(:ngs_run).permit(:name, :primer_mismatches, :quality_threshold, :tag_mismates)
  end
end
