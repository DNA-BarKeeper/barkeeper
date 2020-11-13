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

class AlignmentsController < ApplicationController
  load_and_authorize_resource

  before_action :set_alignment, only: %i[show edit update destroy]

  def index
    @alignments = Alignment.all
  end

  def show; end

  def new
    @alignment = Alignment.new
  end

  def edit; end

  def create
    @alignment = Alignment.new(alignment_params)

    respond_to do |format|
      if @alignment.save
        format.html { redirect_to @alignment, notice: 'Alignment was successfully created.' }
        format.json { render :show, status: :created, location: @alignment }
      else
        format.html { render :new }
        format.json { render json: @alignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @alignment.update(alignment_params)
        format.html { redirect_to @alignment, notice: 'Alignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @alignment }
      else
        format.html { render :edit }
        format.json { render json: @alignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @alignment.destroy
    respond_to do |format|
      format.html { redirect_to alignments_url, notice: 'Alignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_alignment
    @alignment = Alignment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def alignment_params
    params.require(:alignment).permit(:name, :URL)
  end
end
