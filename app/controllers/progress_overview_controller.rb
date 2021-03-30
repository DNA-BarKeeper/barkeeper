# frozen_string_literal: true

class ProgressOverviewController < ApplicationController
  include ProjectConcern
  include ProgressOverviewConcern

  def index
    authorize! :index, :overview_diagram
  end

  # returns JSON containing the number of target species for each family
  def all_species
    authorize! :all_species, :overview_diagram
    render json: all_taxa_json(current_project_id)
  end

  # returns JSON with the number of finished species for each family
  def finished_species_marker
    @current_project_id = current_project_id
    authorize! :finished_species_marker, :overview_diagram
    render json: finished_taxa_json(current_project_id, params[:marker_id])
  end
end
