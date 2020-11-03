# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :set_home, only: %i[show edit update destroy]

  def overview
    authorize! :overview, :home
  end

  def about
    @about_page = true
    @home = Home.where(active: true).first
    authorize! :about, :home
  end

  def impressum
    @about_page = true
    authorize! :impressum, :home
  end

  def privacy_policy
    @about_page = true
    authorize! :privacy_policy, :home
  end

  def new
    @home = Home.new
  end

  def edit;
    authorize! :edit, :home
  end

  def create
    @home = Home.new(home_params)
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

  def destroy
    @home.destroy
  end

  private

  def set_home
    @home = Home.find(params[:id])
  end

  def home_params
    params.require(:home).permit(:active, :description, :subtitle, :title, :background_image, :project_logo,
                                 :delete_background_image, :delete_project_logo)
  end
end
