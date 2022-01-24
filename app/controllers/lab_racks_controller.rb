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

class LabRacksController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_lab_rack, only: %i[show edit update destroy]

  # GET /lab_racks
  # GET /lab_racks.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: LabRackDatatable.new(view_context, current_project_id) }
    end
  end

  # GET /lab_racks/1
  # GET /lab_racks/1.json
  def show; end

  # GET /lab_racks/new
  def new
    @lab_rack = LabRack.new
  end

  # GET /lab_racks/1/edit
  def edit; end

  # POST /lab_racks
  # POST /lab_racks.json
  def create
    @lab_rack = LabRack.new(lab_rack_params)
    @lab_rack.add_project(current_project_id)

    respond_to do |format|
      if @lab_rack.save
        format.html { redirect_to lab_racks_path, notice: 'Lab rack was successfully created.' }
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
        format.html { redirect_to lab_racks_path, notice: 'Lab rack was successfully updated.' }
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
    params.require(:lab_rack).permit(:shelf_id, :rack_position, :rackcode, project_ids: [])
  end
end
