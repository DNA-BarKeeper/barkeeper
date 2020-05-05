# frozen_string_literal: true

class ProjectsController < ApplicationController
  load_and_authorize_resource

  before_action :set_project, only: %i[show edit update destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = if user_signed_in?
                  current_user.admin? || current_user.supervisor? ? Project.all : current_user.projects
                else
                  []
                end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show; end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit; end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search_taxa
    @result = PgSearch.multisearch(params[:query])
  end

  def add_to_taxa
    taxa = {}
    taxa[:hot] = params[:higherordertaxon][:id] if params[:higherordertaxon]
    taxa[:order] = params[:order][:id] if params[:order]
    taxa[:family] = params[:family][:id] if params[:family]
    taxa[:species] = params[:species][:id] if params[:species]

    Project.where(id: params[:project][:id]).each { |project| project.add_project_to_taxa(taxa) }

    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Added project(s) to all selected taxa.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :description, :start, :due, user_ids: [])
  end
end
