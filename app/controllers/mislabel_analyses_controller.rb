# frozen_string_literal: true

class MislabelAnalysesController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: MislabelAnalysisDatatable.new(view_context) }
    end
  end

  def show
    @mislabel_analysis = MislabelAnalysis.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: MislabelAnalysisResultDatatable.new(view_context, params[:id]) }
    end
  end

  def create
    # Allow user to select criteria for a ms search
    # Then automatically generate fasta and tax file on server from search results
    # Run python script with these files as worker process
    # Redirect back to index with notification that this may take a long time
    # Analyse output file & create and link mislabel objects
  end

  def destroy
    @mislabel_analysis.destroy
    respond_to do |format|
      format.html { redirect_to mislabel_analyses_path, notice: 'SATIVA analysis was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    file = params[:file]

    if file.blank? || File.extname(file.original_filename) != '.mis'
      redirect_to mislabel_analyses_path, alert: 'Please select a SATIVA output file (*.mis) to import results.'
    else
      results = File.new(params[:file].path)
      title = File.basename(file.original_filename, '.mis')

      @mislabel_analysis = MislabelAnalysis.import(results, title)
      redirect_to mislabel_analysis_path(@mislabel_analysis), notice: 'Imported analysis output. Possibly mislabeled sequences have been marked.'
    end
  end
end
