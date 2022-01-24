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

# frozen_string_literal: true

class MislabelAnalysesController < ApplicationController
  load_and_authorize_resource

  before_action :set_mislabel_analysis, only: %i[show destroy import download_results]

  http_basic_authenticate_with name: ENV['API_USER_NAME'], password: ENV['API_PASSWORD'], only: :download_results
  skip_before_action :verify_authenticity_token, only: :download_results

  def index
    respond_to do |format|
      format.html
      format.json { render json: MislabelAnalysisDatatable.new(view_context) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: MislabelAnalysisResultDatatable.new(view_context, params[:id]) }
    end
  end

  def destroy
    @mislabel_analysis.destroy
    respond_to do |format|
      format.html { redirect_to mislabel_analyses_path, notice: 'SATIVA analysis was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def download_results
    if @mislabel_analysis.download_results
      send_data("SATIVA results were successfully imported into the BarKeeper web app!\n", filename: 'msg.txt', type: 'application/txt')
    else
      send_data("ERROR: The result file could not be found on the server!\n", filename: 'msg.txt', type: 'application/txt')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mislabel_analysis
    @mislabel_analysis = MislabelAnalysis.find(params[:id])
  end
end
