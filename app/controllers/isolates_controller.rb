#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

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
    @isolates = Isolate.select(:display_name, :id).where('isolates.display_name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id)
    render json: @isolates.map{ |isolate| {:id=> isolate.id, :name => isolate.display_name }}
  end

  def import
    file = params[:file]

    IsolateImporter.perform_async(file, current_user.default_project_id)
    redirect_to isolates_path,
                notice: "Isolate and specimen data will be imported in the background."
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
        format.html { redirect_to edit_isolate_path(@isolate), notice: 'Isolate was successfully created.' }
        format.json { render :edit, status: :created, location: @isolate }
      else
        format.html { render :new }
        format.json { render json: @isolate.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @isolate.update(isolate_params)
        format.html { redirect_to edit_isolate_path(@isolate), notice: 'Isolate was successfully updated.' }
        format.json { render :edit, status: :ok, location: @isolate }
      else
        format.html { render :edit }
        format.json { render json: @isolate.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @isolate.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location: isolates_url) }
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
    params.require(:isolate).permit(:id, :isolation_date, :user_id, :well_pos_plant_plate,
                                    :lab_isolation_nr, :tissue_id, :plant_plate_id, :individual_id,
                                    :dna_bank_id, :negative_control, project_ids: [],
                                    aliquots_attributes: [:id, :comment, :concentration, :is_original, :lab_id,
                                                          :well_pos_micronic_plate, :micronic_tube, :micronic_plate_id,
                                                          :isolate_id, :_destroy])
  end
end
