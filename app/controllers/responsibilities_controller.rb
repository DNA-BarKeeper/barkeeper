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
