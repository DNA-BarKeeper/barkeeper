class UsersController < ApplicationController
  before_action :authenticate_user!

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.name.nil?
      #happens automatically:
      # redirect_to '/users/sign_in'
    elsif current_user.name == 'Kai Müller'
      @users = User.all
    else
      redirect_to root_path, alert: 'Access not allowed.'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    if current_user.name == 'Kai Müller'
      set_user
    else
      redirect_to root_path, alert: 'Access not allowed.'
    end
  end

  def update
    if current_user.name == 'Kai Müller'
      set_user
      if @user.update(user_params)
        redirect_to users_path, notice: 'User was successfully updated.'
      else
        redirect_to edit_user_path(@user), alert: 'User could not be updated.'
      end
    else
      redirect_to root_path, alert: 'Access not allowed.'
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :project_ids => [])
  end
end
