# frozen_string_literal: true

class OverviewDiagramController < ApplicationController
  include ProjectConcern
  include OverviewDiagramConcern

  def index
    authorize! :index, :overview_diagram
  end

  # returns JSON containing the number of target species for each family
  def all_species
    authorize! :all_species, :overview_diagram
    render json: all_taxa_json(current_project_id)
  end

  # returns JSON with the number of finished species for each family
  def finished_species_trnlf
    authorize! :finished_species_trnlf, :overview_diagram
    render json: finished_taxa_json(current_project_id, 4)
  end

  def finished_species_its
    authorize! :finished_species_its, :overview_diagram
    render json: finished_taxa_json(current_project_id, 5)
  end

  def finished_species_rpl16
    authorize! :finished_species_its, :overview_diagram
    render json: finished_taxa_json(current_project_id, 6)
  end

  def finished_species_trnk_matk
    authorize! :finished_species_its, :overview_diagram
    render json: finished_taxa_json(current_project_id, 7)
  end
end
