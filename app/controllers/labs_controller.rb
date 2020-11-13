#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
# frozen_string_literal: true

class LabsController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_lab, only: %i[show edit update destroy]

  # GET /labs
  # GET /labs.json
  def index
    @labs = Lab.in_project(current_project_id)
  end

  # GET /labs/1
  # GET /labs/1.json
  def show; end

  # GET /labs/new
  def new
    @lab = Lab.new
  end

  # GET /labs/1/edit
  def edit; end

  # POST /labs
  # POST /labs.json
  def create
    @lab = Lab.new(lab_params)
    @lab.add_project(current_project_id)

    respond_to do |format|
      if @lab.save
        format.html { redirect_to labs_path, notice: 'Lab was successfully created.' }
        format.json { render :show, status: :created, location: @lab }
      else
        format.html { render :new }
        format.json { render json: @lab.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /labs/1
  # PATCH/PUT /labs/1.json
  def update
    respond_to do |format|
      if @lab.update(lab_params)
        format.html { redirect_to labs_path, notice: 'Lab was successfully updated.' }
        format.json { render :show, status: :ok, location: @lab }
      else
        format.html { render :edit }
        format.json { render json: @lab.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /labs/1
  # DELETE /labs/1.json
  def destroy
    @lab.destroy
    respond_to do |format|
      format.html { redirect_to labs_url, notice: 'Lab was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lab
    @lab = Lab.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lab_params
    params.require(:lab).permit(:labcode, project_ids: [])
  end
end
