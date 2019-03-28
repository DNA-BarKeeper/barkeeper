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

  def import
    #TODO refactor
    # file = params[:file]
    #
    # if file.blank? || File.extname(file.original_filename) != '.mis'
    #   redirect_to mislabel_analyses_path, alert: 'Please select a SATIVA output file (*.mis) to import results.'
    # else
    #   results = File.new(params[:file].path)
    #   title = File.basename(file.original_filename, '.mis')
    #
    #   @mislabel_analysis = MislabelAnalysis.import(results, title)
    #   redirect_to mislabel_analysis_path(@mislabel_analysis), notice: 'Imported analysis output. Possibly mislabeled sequences have been marked.'
    # end
  end

  def download_results
    @mislabel_analysis.download_results
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mislabel_analysis
    @mislabel_analysis = MislabelAnalysis.find(params[:id])
  end
end
