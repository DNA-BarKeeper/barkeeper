class ClustersController < ApplicationController
  load_and_authorize_resource

  before_action :set_cluster, only: %i[edit update destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: ClusterDatatable.new(view_context, current_user.id) }
    end
  end

  def new
    @cluster = Cluster.new
  end

  def create
    @cluster = Cluster.create!(cluster_params)

    redirect_to @cluster
  end

  def edit; end

  def destroy
    @cluster.destroy
    respond_to do |format|
      format.html { redirect_to clusters_path, notice: 'Cluster was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cluster
    @cluster = Cluster.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cluster_params
    params.require(:clusters).permit(:centroid_sequence, :fasta, :reverse_complement, :running_number, :sequence_count,
                                     :isolate_id, :marker_id, :ngs_run_id)
  end
end
