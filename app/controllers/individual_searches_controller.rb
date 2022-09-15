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

class IndividualSearchesController < ApplicationController
  load_and_authorize_resource

  before_action :set_individual_search, only: %i[show edit update destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: IndividualSearchesDatatable.new(view_context, current_user.id) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: IndividualSearchResultDatatable.new(view_context, params[:id]) }
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @individual_search.update(individual_search_params)
        format.html { redirect_to individual_search_path(@individual_search), notice: 'Search parameters were successfully updated.' }
        format.json { render :show, status: :ok, location: @individual_search }
      else
        format.html { render :edit }
        format.json { render json: @individual_search.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @individual_search = IndividualSearch.new
  end

  def create
    @individual_search = IndividualSearch.new(individual_search_params)

    respond_to do |format|
      if @individual_search.save
        if user_signed_in?
          @individual_search.update(user_id: current_user.id)
          @individual_search.update(project_id: current_user.default_project_id)
        end

        format.html { redirect_to @individual_search }
        format.json { render :show, status: :created, location: @individual_search }
      else
        format.html { render :new }
        format.json { render json: @individual_search.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @individual_search.destroy
    respond_to do |format|
      format.html { redirect_to individual_searches_url, notice: 'Individual search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export_as_csv
    @individual_search = IndividualSearch.find(params[:individual_search_id])
    file_name = @individual_search.title.empty? ? "specimen_search_#{@individual_search.created_at}" : @individual_search.title
    send_data(@individual_search.to_csv, filename: "#{file_name}.csv", type: 'application/csv')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_individual_search
    @individual_search = IndividualSearch.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def individual_search_params
    params.require(:individual_search).permit(:title, :DNA_bank_id, :has_issue, :has_problematic_location,
                                              :has_taxon, :taxon, :specimen_id, :collection)
  end
end
