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

class FreezersController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_freezer, only: %i[show edit update destroy]

  # GET /freezers
  # GET /freezers.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: FreezerDatatable.new(view_context, current_project_id) }
    end
  end

  # GET /freezers/1
  # GET /freezers/1.json
  def show; end

  # GET /freezers/new
  def new
    @freezer = Freezer.new
  end

  # GET /freezers/1/edit
  def edit; end

  # POST /freezers
  # POST /freezers.json
  def create
    @freezer = Freezer.new(freezer_params)
    @freezer.add_project(current_project_id)

    respond_to do |format|
      if @freezer.save
        format.html { redirect_to freezers_path, notice: 'Freezer was successfully created.' }
        format.json { render :show, status: :created, location: @freezer }
      else
        format.html { render :new }
        format.json { render json: @freezer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /freezers/1
  # PATCH/PUT /freezers/1.json
  def update
    respond_to do |format|
      if @freezer.update(freezer_params)
        format.html { redirect_to freezers_path, notice: 'Freezer was successfully updated.' }
        format.json { render :show, status: :ok, location: @freezer }
      else
        format.html { render :edit }
        format.json { render json: @freezer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /freezers/1
  # DELETE /freezers/1.json
  def destroy
    @freezer.destroy
    respond_to do |format|
      format.html { redirect_to freezers_url, notice: 'Freezer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_freezer
    @freezer = Freezer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def freezer_params
    params.require(:freezer).permit(:freezercode, :lab_id, project_ids: [])
  end
end
