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

class ShelvesController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_shelf, only: %i[show edit update destroy]

  # GET /shelves
  # GET /shelves.json
  def index
    @shelves = Shelf.in_project(current_project_id).order(:name)
  end

  # GET /shelves/1
  # GET /shelves/1.json
  def show; end

  # GET /shelves/new
  def new
    @shelf = Shelf.new
  end

  # GET /shelves/1/edit
  def edit; end

  # POST /shelves
  # POST /shelves.json
  def create
    @shelf = Shelf.new(shelf_params)
    @shelf.add_project(current_project_id)

    respond_to do |format|
      if @shelf.save
        format.html { redirect_to @shelf, notice: 'Shelf was successfully created.' }
        format.json { render :show, status: :created, location: @shelf }
      else
        format.html { render :new }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shelves/1
  # PATCH/PUT /shelves/1.json
  def update
    respond_to do |format|
      if @shelf.update(shelf_params)
        format.html { redirect_to @shelf, notice: 'Shelf was successfully updated.' }
        format.json { render :show, status: :ok, location: @shelf }
      else
        format.html { render :edit }
        format.json { render json: @shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.json
  def destroy
    @shelf.destroy
    respond_to do |format|
      format.html { redirect_to shelves_url, notice: 'Shelf was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_shelf
    @shelf = Shelf.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shelf_params
    params.require(:shelf).permit(:name, project_ids: [])
  end
end
