class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.all.order(:id)
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
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?

      if @user.update(user_params)
        redirect_to users_path, notice: 'User was successfully updated.'
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

      if @user.destroy
        redirect_to users_path, notice: 'User was successfully destroyed.'
      end
    end
  end

  def home
    @user = User.find(params[:id])
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :lab_id, :project_ids => [], :responsibility_ids => [])
  end
end
