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

class MarkerSequenceSearchesController < ApplicationController
  load_and_authorize_resource

  before_action :set_marker_sequence_search, only: %i[export_as_fasta export_as_pde]

  def index
    respond_to do |format|
      format.html
      format.json { render json: MarkerSequenceSearchDatatable.new(view_context, current_user.id) }
    end
  end

  def new
    @marker_sequence_search = MarkerSequenceSearch.new
  end

  def create
    @marker_sequence_search = MarkerSequenceSearch.create!(marker_sequence_search_params)

    respond_to do |format|
      if @marker_sequence_search.save
        if user_signed_in?
          @marker_sequence_search.update(user_id: current_user.id)
          @marker_sequence_search.update(project_id: current_user.default_project_id)
        end

        format.html { redirect_to @marker_sequence_search }
        format.json { render :show, status: :created, location: @marker_sequence_search }
      else
        format.html { render :new }
        format.json { render json: @marker_sequence_search.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @marker_sequence_search = MarkerSequenceSearch.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: MarkerSequenceSearchResultDatatable.new(view_context, params[:id]) }
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @marker_sequence_search.update(marker_sequence_search_params)
        format.html { redirect_to marker_sequence_search_path(@marker_sequence_search), notice: 'Search parameters were successfully updated.' }
        format.json { render :show, status: :ok, location: @marker_sequence_search }
      else
        format.html { render :edit }
        format.json { render json: @marker_sequence_search.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @marker_sequence_search.destroy

    respond_to do |format|
      format.html { redirect_to marker_sequence_searches_path, notice: 'Marker sequence search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export_as_fasta
    file_name = @marker_sequence_search.title.empty? ? "marker_sequence_search_#{@marker_sequence_search.created_at}" : @marker_sequence_search.title
    send_data(MarkerSequenceSearch.fasta(@marker_sequence_search.marker_sequences, metadata: true), filename: "#{file_name}.fasta", type: 'application/txt')
  end

  def export_as_pde
    file_name = @marker_sequence_search.title.empty? ? "marker_sequence_search_#{@marker_sequence_search.created_at}" : @marker_sequence_search.title
    send_data(MarkerSequenceSearch.pde(@marker_sequence_search.marker_sequences, {}), filename: "#{file_name}.pde", type: 'application/txt')
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def marker_sequence_search_params
    params.require(:marker_sequence_search).permit(:title, :name, :has_taxon, :has_warnings, :marker, :taxon,
                                                   :specimen, :verified, :verified_by, :max_length, :min_length,
                                                   :max_age, :max_update, :min_age, :min_update, :project_id, :no_isolate)
  end

  def set_marker_sequence_search
    @marker_sequence_search = MarkerSequenceSearch.find(params[:marker_sequence_search_id])
  end
end
