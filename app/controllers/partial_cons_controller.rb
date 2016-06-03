class PartialConsController < ApplicationController

  before_action :set_partial_con, only: [:show_page]

  def show_page
    respond_to do |format|
      format.json {

        render :json => @partial_con.to_json_for_page(params[:page], params[:width_in_bases])
      }
    end
  end

  def set_partial_con
    @partial_con= PartialCon.includes(:primer_reads).find(params[:id])
  end

  def partial_con_params
    params.require(:partial_con).permit(:page, :width_in_bases)
  end


end
