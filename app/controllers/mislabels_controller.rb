# frozen_string_literal: true

class MislabelsController < ApplicationController
  load_and_authorize_resource

  before_action :set_mislabel, only: :solve

  def solve
    if @mislabel.solved_by || @mislabel.solved
      redirect_back(fallback_location: marker_sequences_path, warning: 'Mislabel warning was already marked as solved.')
    else
      @mislabel.update(solved_by: current_user.id, solved_at: Time.now, solved: true)
      redirect_back(fallback_location: marker_sequences_path, notice: 'Mislabel warning marked as solved.')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mislabel
    @mislabel = Mislabel.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mislabel_params
    params.require(:mislabel).permit(:solved, :solved_by, :solved_at)
  end
end
