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

class MarkerSequencesController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_marker_sequence, only: %i[show edit update destroy]

  # GET /marker_sequences
  # GET /marker_sequences.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: MarkerSequenceDatatable.new(view_context, current_project_id) }
    end
  end

  def filter
    @marker_sequences = MarkerSequence.where('name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).order(:name).limit(100)
    size = MarkerSequence.where('name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).order(:name).size

    if size > 100
      message = "and #{size} more..."
      render json: @marker_sequences.map(&:name).push(message)
    else
      render json: @marker_sequences.map(&:name)
    end
  end

  # GET /marker_sequences/1
  # GET /marker_sequences/1.json
  def show; end

  # GET /marker_sequences/new
  def new
    @marker_sequence = MarkerSequence.new
  end

  # GET /marker_sequences/1/edit
  def edit; end

  # POST /marker_sequences
  # POST /marker_sequences.json
  def create
    @marker_sequence = MarkerSequence.new(marker_sequence_params)
    @marker_sequence.add_project(current_project_id)

    @marker_sequence.save

    @marker_sequence.generate_name if @marker_sequence.name.empty?

    respond_to do |format|
      if @marker_sequence.save
        format.html { redirect_to marker_sequences_path, notice: 'Marker sequence was successfully created.' }
        format.json { render :show, status: :created, location: @marker_sequence }
      else
        format.html { render :new }
        format.json { render json: @marker_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marker_sequences/1
  # PATCH/PUT /marker_sequences/1.json
  def update
    @marker_sequence.update(marker_sequence_params)

    @marker_sequence.generate_name if @marker_sequence.name.empty?

    redirect_to edit_marker_sequence_path(@marker_sequence), notice: 'Marker sequence was successfully updated.'
  end

  # DELETE /marker_sequences/1
  # DELETE /marker_sequences/1.json
  def destroy
    @marker_sequence.destroy
    respond_to do |format|
      format.html { redirect_to marker_sequences_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_marker_sequence
    @marker_sequence = MarkerSequence.includes(isolate: :individual).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def marker_sequence_params
    params.require(:marker_sequence).permit(:genbank, :name, :sequence, :isolate_display_name, :marker_id, :contig_id, :reference, project_ids: [])
  end
end
