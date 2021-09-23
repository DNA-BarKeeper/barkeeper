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

class HomesController < ApplicationController
  before_action :set_home, only: %i[show edit update delete_background_image]

  def multisearch_app
    authorize! :multisearch_app, :home
    @results = PgSearch.multisearch(params[:search]).paginate(:page => params[:page], :per_page => 5)
  end

  def progress
    authorize! :progress, :home
  end

  def about
    @about_page = true
    @home = Home.where(active: true).first
    authorize! :about, :home
  end

  def documentation
    @about_page = true
    authorize! :documentation, :home
  end

  def impressum
    @about_page = true
    authorize! :impressum, :home
  end

  def privacy_policy
    @about_page = true
    authorize! :privacy_policy, :home
  end

  def edit;
    authorize! :edit, :home
  end

  def update
    authorize! :update, :home

    respond_to do |format|
      if @home.update(home_params)
        format.html { redirect_to root_path, notice: 'Home parameters were successfully updated.' }
        format.json { render :root, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @home.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_background_image
    authorize! :delete_background_image, :home

    @home.remove_background_image_attachment
    redirect_back(fallback_location: root_path)
  end

  private

  def set_home
    @home = Home.find(params[:id])
  end

  def home_params
    params.require(:home).permit(:description, :subtitle, :title, :background_image, :main_logo_id,
                                 logos_attributes: [:title, :url, :image, :display, :display_pos_index, :_destroy, :id])
  end
end
