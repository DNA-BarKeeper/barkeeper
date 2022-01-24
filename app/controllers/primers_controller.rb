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

class PrimersController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_primer, only: %i[show edit update destroy]

  def index
    @primers = Primer.includes(:marker).in_project(current_project_id)
  end

  def show; end

  def new
    @primer = Primer.new
  end
  def edit; end

  def create
    @primer = Primer.new(primer_params)
    @primer.add_project(current_project_id)

    respond_to do |format|
      if @primer.save
        format.html { redirect_to primers_path, notice: 'Primer was successfully created.' }
        format.json { render :show, status: :created, location: @primer }
      else
        format.html { render :new }
        format.json { render json: @primer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @primer.update(primer_params)
        format.html { redirect_to primers_path, notice: 'Primer was successfully updated.' }
        format.json { render :show, status: :ok, location: @primer }
      else
        format.html { render :edit }
        format.json { render json: @primer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @primer.destroy
    respond_to do |format|
      format.html { redirect_to primers_url }
      format.json { head :no_content }
    end
  end

  def import
    Primer.import(params[:file], current_project_id)
    redirect_to primers_path, notice: 'Imported.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_primer
    @primer = Primer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def primer_params
    params.require(:primer).permit(:alt_name, :position, :file, :name, :sequence, :reverse, :marker_id, project_ids: [])
  end
end
