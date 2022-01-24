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

class HerbariaController < ApplicationController
  load_and_authorize_resource

  before_action :set_herbarium, only: [:show, :edit, :update, :destroy]

  # GET /herbaria
  # GET /herbaria.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: HerbariumDatatable.new(view_context) }
    end
  end

  # GET /herbaria/1
  # GET /herbaria/1.json
  def show;end

  # GET /herbaria/new
  def new
    @herbarium = Herbarium.new
  end

  # GET /herbaria/1/edit
  def edit;end

  # POST /herbaria
  # POST /herbaria.json
  def create
    @herbarium = Herbarium.new(herbarium_params)

    respond_to do |format|
      if @herbarium.save
        format.html { redirect_to @herbarium, notice: 'Herbarium was successfully created.' }
        format.json { render :show, status: :created, location: @herbarium }
      else
        format.html { render :new }
        format.json { render json: @herbarium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /herbaria/1
  # PATCH/PUT /herbaria/1.json
  def update
    respond_to do |format|
      if @herbarium.update(herbarium_params)
        format.html { redirect_to @herbarium, notice: 'Herbarium was successfully updated.' }
        format.json { render :show, status: :ok, location: @herbarium }
      else
        format.html { render :edit }
        format.json { render json: @herbarium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /herbaria/1
  # DELETE /herbaria/1.json
  def destroy
    @herbarium.destroy
    respond_to do |format|
      format.html { redirect_to herbaria_url, notice: 'Herbarium was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_herbarium
      @herbarium = Herbarium.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def herbarium_params
      params.require(:herbarium).permit(:name, :acronym)
    end
end
