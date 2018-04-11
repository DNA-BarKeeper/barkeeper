class OverviewDiagramController < ApplicationController

  def index
    authorize! :index, :overview_diagram
  end

  # returns JSON containing the number of target species for each family
  def all_species
    authorize! :all_species, :overview_diagram
    render json: OverviewAllTaxaMatview.all_taxa_json
  end

  # returns JSON with the number of finished species for each family
  def finished_species
    authorize! :finished_species, :overview_diagram
    render :json => OverviewFinishedTaxaMatview.finished_taxa_json
  end
end
