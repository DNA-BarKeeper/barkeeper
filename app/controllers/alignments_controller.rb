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
