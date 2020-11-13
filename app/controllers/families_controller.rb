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

class FamiliesController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_family, only: %i[show edit update destroy]

  # GET /families
  # GET /families.json

  def index
    @families = Family.includes(:order).in_project(current_project_id).order('families.name asc').references(:order)
    respond_to :html, :json
  end

  def filter
    @families = Family.in_project(current_project_id).order(:name).where('families.name ilike ?', "%#{params[:term]}%")
    render json: @families.map(&:name)
  end

  def show_species
    respond_to do |format|
      format.html
      format.json { render json: SpeciesDatatable.new(view_context, params[:id], nil, current_project_id) }
    end
  end

  # GET /families/1
  # GET /families/1.json
  def show; end

  # GET /families/new
  def new
    @family = Family.new
  end

  # GET /families/1/edit
  def edit; end

  # POST /families
  # POST /families.json
  def create
    @family = Family.new(family_params)
    @family.add_project(current_project_id)

    respond_to do |format|
      if @family.save
        format.html { redirect_to families_path, notice: 'Family was successfully created.' }
        format.json { render :show, status: :created, location: @family }
      else
        format.html { render :new }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /families/1
  # PATCH/PUT /families/1.json
  def update
    respond_to do |format|
      if @family.update(family_params)
        format.html { redirect_to families_path, notice: 'Family was successfully updated.' }
        format.json { render :show, status: :ok, location: @family }
      else
        format.html { render :edit }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /families/1
  # DELETE /families/1.json
  def destroy
    @family.destroy
    respond_to do |format|
      format.html { redirect_to families_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_family
    @family = Family.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def family_params
    params.require(:family).permit(:name, :author, :order_id, :term, project_ids: [])
  end
end
