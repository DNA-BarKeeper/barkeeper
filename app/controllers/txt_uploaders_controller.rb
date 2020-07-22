# frozen_string_literal: true

class TxtUploadersController < ApplicationController
  load_and_authorize_resource

  before_action :set_txt_uploader, only: %i[show edit update destroy]

  # GET /txt_uploaders
  # GET /txt_uploaders.json
  def index
    @txt_uploaders = TxtUploader.all
  end

  # GET /txt_uploaders/1
  # GET /txt_uploaders/1.json
  def show; end

  # GET /txt_uploaders/new
  def new
    @txt_uploader = TxtUploader.new
  end

  # GET /txt_uploaders/1/edit
  def edit; end

  # POST /txt_uploaders
  # POST /txt_uploaders.json
  def create
    @txt_uploader = TxtUploader.new(txt_uploader_params)

    respond_to do |format|
      if @txt_uploader.save
        format.html { redirect_to @txt_uploader, notice: 'Txt uploader was successfully created.' }
        format.json { render :show, status: :created, location: @txt_uploader }
      else
        format.html { render :new }
        format.json { render json: @txt_uploader.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /txt_uploaders/1
  # PATCH/PUT /txt_uploaders/1.json
  def update
    respond_to do |format|
      if @txt_uploader.update(txt_uploader_params)
        format.html { redirect_to @txt_uploader, notice: 'Txt uploader was successfully updated.' }
        format.json { render :show, status: :ok, location: @txt_uploader }
      else
        format.html { render :edit }
        format.json { render json: @txt_uploader.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /txt_uploaders/1
  # DELETE /txt_uploaders/1.json
  def destroy
    @txt_uploader.destroy
    respond_to do |format|
      format.html { redirect_to txt_uploaders_url, notice: 'Txt uploader was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_txt_uploader
    @txt_uploader = TxtUploader.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def txt_uploader_params
    params[:txt_uploader]
  end
end
