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
  def finished_species_trnlf
    authorize! :finished_species_trnlf, :overview_diagram
    render json: OverviewFinishedTaxaMatview.finished_taxa_json(Marker.find(4).name)
  end

  def finished_species_its
    authorize! :finished_species_its, :overview_diagram
    render json: OverviewFinishedTaxaMatview.finished_taxa_json(Marker.find(5).name)
  end

  def finished_species_rpl16
    authorize! :finished_species_its, :overview_diagram
    render json: OverviewFinishedTaxaMatview.finished_taxa_json(Marker.find(6).name)
  end

  def finished_species_trnk_matk
    authorize! :finished_species_its, :overview_diagram
    render json: OverviewFinishedTaxaMatview.finished_taxa_json(Marker.find(7).name)
  end
end
