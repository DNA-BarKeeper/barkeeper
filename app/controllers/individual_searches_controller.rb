# frozen_string_literal: true

class IndividualSearchesController < ApplicationController
  load_and_authorize_resource

  before_action :set_individual_search, only: %i[show edit update destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: IndividualSearchesDatatable.new(view_context, current_user.id) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: IndividualSearchResultDatatable.new(view_context, params[:id]) }
    end
  end

  def new
    @individual_search = IndividualSearch.new
  end

  def create
    @individual_search = IndividualSearch.new(individual_search_params)

    @individual_search.update(user_id: current_user.id)
    @individual_search.update(project_id: current_user.default_project_id)

    redirect_to @individual_search
  end

  def destroy
    @individual_search.destroy
    respond_to do |format|
      format.html { redirect_to individual_searches_url, notice: 'Individual search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_individual_search
    @individual_search = IndividualSearch.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def individual_search_params
    params.require(:individual_search).permit(:title, :DNA_bank_id, :family, :has_issue, :has_problematic_location,
                                              :has_species, :order, :species, :specimen_id, :herbarium)
  end
end
