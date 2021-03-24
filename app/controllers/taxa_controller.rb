class TaxaController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_taxon, only: %i[show edit update destroy]

  # returns taxonomic hierarchy as JSON
  def index
    @taxa = Taxon.order(:taxonomic_rank, :scientific_name).in_project(current_project_id)
  end

  # returns hierarchy of taxa as JSON
  def taxonomy_tree
    parent_id = params[:parent_id]
    render json: Taxon.subtree_json(parent_id)
  end

  def show; end

  def new
    @taxon = Taxon.new
  end

  def edit; end

  def create
    @taxon = Taxon.new(taxon_params)
    @taxon.add_project(current_project_id)

    respond_to do |format|
      if @taxon.save
        format.html { redirect_to taxa_path, notice: 'Taxon was successfully created.' }
        format.json { render :show, status: :created, location: @taxon }
      else
        format.html { render :new }
        format.json { render json: @taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @taxon.update(taxon_params)
        format.html { redirect_to taxa_path, notice: 'Taxon was successfully updated.' }
        format.json { render :show, status: :ok, location: @taxon }
      else
        format.html { render :edit }
        format.json { render json: @taxon.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @taxon.destroy
    respond_to do |format|
      format.html { redirect_to taxa_path, notice: 'Taxon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_taxon
    @taxon = Taxon.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def taxon_params
    params.require(:taxon).permit(:parent_id, :position, :scientific_name, :common_name, :author, :comment, :synonym,
                                  :taxonomic_rank, project_ids: [])
  end
end
