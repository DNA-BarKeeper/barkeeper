# frozen_string_literal: true

class ProgressOverviewController < ApplicationController
  include ProjectConcern
  include ProgressOverviewConcern

  def index
    authorize! :index, :progress_overview
  end

  def progress_tree
    authorize! :progress_tree, :progress_overview
    render json: progress_tree_json(current_project_id, params[:marker_id])
  end

  # returns JSON containing the number of target species for each family
  def all_species
    authorize! :all_species, :progress_overview
    render json: all_taxa_json(current_project_id)
  end

  # returns JSON with the number of finished species for each family
  def finished_species_marker
    @current_project_id = current_project_id
    authorize! :finished_species_marker, :progress_overview
    render json: finished_taxa_json(current_project_id, params[:marker_id])
  end
end
