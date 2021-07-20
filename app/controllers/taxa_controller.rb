class TaxaController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_taxon, only: %i[show edit update destroy associated_specimen]

  def index
    @taxa = Taxon.order(:taxonomic_rank, :scientific_name).in_project(current_project_id)
  end

  # returns hierarchy of taxa as JSON
  def taxonomy_tree
    parent_id = params[:parent_id]
    root_id = params[:root_id]
    render json: Taxon.subtree_json(current_project_id, parent_id, root_id)
  end

  def associated_specimen
    render json: @taxon.specimen_json
  end

  def find_ancestry
    taxon_name = params[:taxon_name]
    render plain: Taxon.find_ancestry(taxon_name)
  end

  def show_individuals
    respond_to do |format|
      format.html
      format.json { render json: IndividualDatatable.new(view_context, params[:id], current_project_id) }
    end
  end

  def show_children
    respond_to do |format|
      format.html
      format.json { render json: TaxonDatatable.new(view_context, params[:id], current_project_id) }
    end
  end

  def filter
    @taxa = Taxon.where('scientific_name ILIKE ?', "%#{params[:term]}%").in_project(current_project_id).order(:scientific_name)
    render json: @taxa.map{ |taxon| {:id=> taxon.id, :name => taxon.scientific_name }}
  end

  def export_as_csv
    authorize! :export_as_csv, :taxon

    send_data(Taxon.to_csv(current_project_id),
              filename: "taxa_project_#{Project.find(current_project_id).name}.csv",
              type: 'application/csv')
  end

  def orphans
    respond_to do |format|
      format.html
      format.json { render json: TaxonDatatable.new(view_context, nil, current_project_id) }
    end
  end

  def import_csv
    file = params[:file]
    cnt = Taxon.import_from_csv(file, current_project_id)
    redirect_to taxa_path, notice: "Successfully imported or updated #{cnt} taxon entries."
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
    params.require(:taxon).permit(:parent_id, :parent_name, :position, :scientific_name, :common_name, :author,
                                  :comment, :synonym, :taxonomic_rank, project_ids: [])
  end
end