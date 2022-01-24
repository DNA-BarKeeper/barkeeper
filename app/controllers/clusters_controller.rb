#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

class ClustersController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  before_action :set_cluster, only: %i[edit update destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: ClusterDatatable.new(view_context, nil, current_project_id) }
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

  def show; end

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
    params.require(:clusters).permit(:centroid_sequence, :fasta, :name, :reverse_complement, :running_number, :sequence_count,
                                     :isolate_id, :marker_id, :ngs_run_id)
  end
end
