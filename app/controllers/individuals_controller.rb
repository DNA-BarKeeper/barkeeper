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

class IndividualsController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_individual, only: %i[show edit update destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: IndividualDatatable.new(view_context, nil, current_project_id) }
    end
  end

  def create_xls
    SpecimenExport.perform_async(current_project_id)
    redirect_to individuals_path, notice: "Writing Excel file to S3 in background. May take a minute or so. Download from Specimens index page > 'Download last specimens export'."
  end

  def xls
    require 'open-uri'

    export = SpecimenExporter.last.specimen_export

    if export.attached?
      begin
        send_data(export.blob.download, filename: 'specimens_export.xls',
                  type: 'application/vnd.ms-excel',
                  disposition: 'attachment',
                  stream: 'true',
                  buffer_size: '4096')
      rescue OpenURI::HTTPError # Specimen XLS could not be found on server
        redirect_to individuals_path,
                    alert: 'The specimens XLS file could not be opened. Please try to export it again or contact an administrator if the issue persists.'
      end
    else
      redirect_to individuals_path,
                  notice: 'Please wait while the file is being written to the server.'
    end
  end

  def problematic_specimens
    # Liste aller Bundesländer to check 'state_province' against:
    @states = %w[Baden-Württemberg Bayern Berlin Brandenburg Bremen Hamburg Hessen Mecklenburg-Vorpommern Niedersachsen Nordrhein-Westfalen Rheinland-Pfalz Saarland Sachsen Sachsen-Anhalt Schleswig-Holstein Thüringen]
    @individuals = []

    Individual.in_project(current_project_id).each do |i|
      if i.country == 'Germany'
        @individuals.push(i) unless @states.include? i.state_province
      end
    end
  end

  def filter
    @individuals = Individual.where('individuals.specimen_id ilike ?', "%#{params[:term]}%").in_project(current_project_id).limit(100)
    size = Individual.where('individuals.specimen_id ilike ?', "%#{params[:term]}%").in_project(current_project_id).size

    if size > 100
      message = "and #{size} more..."
      render json: @individuals.map(&:specimen_id).push(message)
    else
      render json: @individuals.map(&:specimen_id)
    end
  end

  # GET /individuals/1
  # GET /individuals/1.json
  def show; end

  # GET /individuals/new
  def new
    @individual = Individual.new
  end

  # GET /individuals/1/edit
  def edit; end

  # POST /individuals
  # POST /individuals.json
  def create
    @individual = Individual.new(individual_params)
    @individual.add_project(current_project_id)

    respond_to do |format|
      if @individual.save
        format.html { redirect_to individuals_path, notice: 'Individual was successfully created.' }
        format.json { render :show, status: :created, location: @individual }
      else
        format.html { render :new }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /individuals/1
  # PATCH/PUT /individuals/1.json
  def update
    respond_to do |format|
      if @individual.update(individual_params)
        format.html { redirect_to individuals_path, notice: 'Individual was successfully updated.' }
        format.json { render :show, status: :ok, location: @individual }
      else
        format.html { render :edit }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /individuals/1
  # DELETE /individuals/1.json
  def destroy
    @individual.destroy
    respond_to do |format|
      format.html { redirect_to individuals_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_individual
    @individual = Individual.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def individual_params
    params.require(:individual).permit(:specimen_id,
                                       :DNA_bank_id,
                                       :collector,
                                       :specimen_id,
                                       :herbarium_code,
                                       :herbarium_id,
                                       :country,
                                       :state_province,
                                       :locality,
                                       :latitude,
                                       :longitude,
                                       :latitude_original,
                                       :longitude_original,
                                       :elevation,
                                       :exposition,
                                       :habitat,
                                       :substrate,
                                       :life_form,
                                       :collectors_field_number,
                                       :collected,
                                       :determination,
                                       :revision,
                                       :confirmation,
                                       :comments,
                                       :species_id,
                                       :species_name,
                                       :tissue_id,
                                       project_ids: [])
  end
end
