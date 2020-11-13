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

class HigherOrderTaxaController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_higher_order_taxon, only: %i[show edit update destroy]


  def index
    @higher_order_taxa = HigherOrderTaxon.order(:position).in_project(current_project_id)
  end

  # returns hierarchy of top-level taxa as JSON
  def hierarchy_tree
    authorize! :all_species, :overview_diagram
    render json: HigherOrderTaxon.hierarchy_json()
  end

  def show_species
    respond_to do |format|
      format.html
      format.json { render json: SpeciesDatatable.new(view_context, nil, params[:id], current_project_id) }
    end
  end

  def show; end

  def new
    @higher_order_taxon = HigherOrderTaxon.new
  end

  def edit; end

  def create
    @higher_order_taxon = HigherOrderTaxon.new(higher_order_taxon_params)
    @higher_order_taxon.add_project(current_project_id)

    respond_to do |format|
      if @higher_order_taxon.save
        format.html { redirect_to higher_order_taxa_path, notice: 'Higher order taxon was successfully created.' }
        format.json { render :show, status: :created, location: @higher_order_taxon }
      else
        format.html { render :new }
        format.json { render json: @higher_order_taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @higher_order_taxon.update(higher_order_taxon_params)
        format.html { redirect_to higher_order_taxa_path, notice: 'Higher order taxon was successfully updated.' }
        format.json { render :show, status: :ok, location: @higher_order_taxon }
      else
        format.html { render :edit }
        format.json { render json: @higher_order_taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @higher_order_taxon.destroy
    respond_to do |format|
      format.html { redirect_to higher_order_taxa_url, notice: 'Higher order taxon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_higher_order_taxon
    @higher_order_taxon = HigherOrderTaxon.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def higher_order_taxon_params
    params.require(:higher_order_taxon).permit(:parent_id, :position, :name, :german_name, marker_ids: [], project_ids: [])
  end
end
