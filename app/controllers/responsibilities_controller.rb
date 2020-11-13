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

class ResponsibilitiesController < ApplicationController
  load_and_authorize_resource

  def index
    @responsibilities = Responsibility.all
  end

  def show; end

  def new
    @responsibility = Responsibility.new
  end

  def edit; end

  def create
    @responsibility = Responsibility.new(responsibility_params)

    respond_to do |format|
      if @responsibility.save
        format.html { redirect_to @responsibility, notice: 'Responsibility was successfully created.' }
        format.json { render :show, status: :created, location: @responsibility }
      else
        format.html { render :new }
        format.json { render json: @responsibility.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @responsibility.update(responsibility_params)
        format.html { redirect_to @responsibility, notice: 'Responsibility was successfully updated.' }
        format.json { render :show, status: :ok, location: @responsibility }
      else
        format.html { render :edit }
        format.json { render json: @responsibility.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @responsibility.destroy
    respond_to do |format|
      format.html { redirect_to responsibilities_path, notice: 'Responsibility was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def responsibility_params
    params.require(:responsibility).permit(:name, :description)
  end
end
