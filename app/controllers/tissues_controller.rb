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

class TissuesController < ApplicationController
  load_and_authorize_resource
  before_action :set_tissue, only: %i[show edit update destroy]

  # GET /tissues
  # GET /tissues.json
  def index
    @tissues = Tissue.all
  end

  # GET /tissues/1
  # GET /tissues/1.json
  def show; end

  # GET /tissues/new
  def new
    @tissue = Tissue.new
  end

  # GET /tissues/1/edit
  def edit; end

  # POST /tissues
  # POST /tissues.json
  def create
    @tissue = Tissue.new(tissue_params)

    respond_to do |format|
      if @tissue.save
        format.html { redirect_to tissues_path, notice: 'Tissue was successfully created.' }
        format.json { render :show, status: :created, location: @tissue }
      else
        format.html { render :new }
        format.json { render json: @tissue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tissues/1
  # PATCH/PUT /tissues/1.json
  def update
    respond_to do |format|
      if @tissue.update(tissue_params)
        format.html { redirect_to tissues_path, notice: 'Tissue was successfully updated.' }
        format.json { render :show, status: :ok, location: @tissue }
      else
        format.html { render :edit }
        format.json { render json: @tissue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tissues/1
  # DELETE /tissues/1.json
  def destroy
    @tissue.destroy
    respond_to do |format|
      format.html { redirect_to tissues_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tissue
    @tissue = Tissue.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tissue_params
    params.require(:tissue).permit(:name)
  end
end
