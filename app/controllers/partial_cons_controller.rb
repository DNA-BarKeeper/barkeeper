# frozen_string_literal: true

class PartialConsController < ApplicationController
  load_and_authorize_resource

  before_action :set_partial_con, only: %i[show_page show_position]

  def show_page
    respond_to do |format|
      format.json do
        render json: @partial_con.to_json_for_page(params[:page], params[:width_in_bases])
      end
    end
  end

  def show_position
    respond_to do |format|
      format.json do
        render json: @partial_con.to_json_for_position(params[:position], params[:width_in_bases])
      end
    end
  end

  private

  def set_partial_con
    @partial_con = PartialCon.includes(:primer_reads).find(params[:id])
  end

  def partial_con_params
    params.require(:partial_con).permit(:page, :position, :width_in_bases)
  end
end
