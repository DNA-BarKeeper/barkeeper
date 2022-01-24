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

class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.all.order(:id)
    respond_to :html, :json
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.admin? && !current_user.admin?
      redirect_to users_path, alert: 'Permission denied.'
    else
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? && params[:user][:password_confirmation].blank?

      if @user.update(user_params)
        if current_user == @user
          redirect_back fallback_location: home_user_path, notice: 'User was successfully updated.'
        else
          redirect_to users_path, notice: 'User was successfully updated.'
        end
      else
        redirect_to edit_user_path(@user), alert: 'User could not be updated.'
      end
    end
  end

  def destroy
    if @user.admin? && !current_user.admin?
      redirect_to users_path, alert: 'Permission denied.'
    else
      @user = User.find(params[:id])

      redirect_to users_path, notice: 'User was successfully destroyed.' if @user.destroy
    end
  end

  def home
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :responsibility,
                                 :lab_id, :default_project_id, project_ids: [])
  end
end
