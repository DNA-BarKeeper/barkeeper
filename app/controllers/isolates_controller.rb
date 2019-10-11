# frozen_string_literal: true

class IsolatesController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_isolate, only: %i[show edit update destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: IsolateDatatable.new(view_context, nil, current_project_id) }
    end
  end

  def duplicates
    respond_to do |format|
      format.html
      format.json { render json: IsolateDatatable.new(view_context, 'duplicates', current_project_id) }
    end
  end

  def no_specimen
    respond_to do |format|
      format.html
      format.json { render json: IsolateDatatable.new(view_context, 'no_specimen', current_project_id) }
    end
  end

  def filter
    @isolates = Isolate.select(:display_name, :id).where('display_name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).limit(50)
    size = Isolate.select(:display_name, :id).where('display_name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).size

    if size > 50
      message = "and #{size - 50} more..."
      render json: @isolates.map(&:display_name).push(message)
    else
      render json: @isolates.map(&:display_name)
    end
  end

  def import
    file = params[:file]
    Isolate.import(file, current_user.default_project_id)
    redirect_to isolates_path, notice: 'Imported.'
  end

  def show; end

  def new
    @isolate = Isolate.new
  end

  def edit; end

  def create
    @isolate = Isolate.new(isolate_params)
    @isolate.add_project(current_project_id)
    @isolate.assign_display_name(isolate_params.fetch('dna_bank_id'), isolate_params.fetch('lab_isolation_nr'))

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

  def update
    respond_to do |format|
      if @isolate.update(isolate_params)
        format.html { redirect_to isolates_path, notice: 'Isolate was successfully updated.' }
        format.json { render :show, status: :ok, location: @isolate }
      else
        format.html { render :edit }
        format.json { render json: @isolate.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @isolate.destroy
    respond_to do |format|
      format.html { redirect_to isolates_url }
      format.json { head :no_content }
    end
  end

  def show_clusters
    respond_to do |format|
      format.html
      format.json { render json: ClusterDatatable.new(view_context, params[:id], current_project_id) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_isolate
    @isolate = Isolate.includes(:individual).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def isolate_params
    params.require(:isolate).permit(:comment_orig, :comment_copy, :micronic_tube_id_copy, :micronic_tube_id_orig,
                                    :concentration_copy, :concentration_orig, :well_pos_micronic_plate_copy,
                                    :well_pos_micronic_plate_orig, :micronic_plate_id_copy, :micronic_plate_id_orig,
                                    :isolation_date, :lab_id_copy, :lab_id_orig, :user_id, :well_pos_plant_plate,
                                    :lab_isolation_nr, :micronic_tube_id, :well_pos_micronic_plate, :concentration,
                                    :tissue_id, :micronic_plate_id, :plant_plate_id, :term, :file, :individual_name,
                                    :query, :dna_bank_id, :negative_control, project_ids: [])
  end
end
