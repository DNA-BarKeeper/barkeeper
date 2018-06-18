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
    # Show all sequences in analysis with columns for:
    #   possible_mislabel (e.g. little check mark)
    #   contig (with link)
    #   species
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
      format.html { redirect_to mislabel_analyses_path, notice: 'Mislabel analysis was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    file = params[:file]

    @mislabel_analysis = MislabelAnalysis.import(file)

    # redirect_to mislabel_analysis_path(@mislabel_analysis), notice: 'Imported analysis output. Possibly mislabeled sequences have been marked.'
    redirect_to mislabel_analyses_path, notice: 'Imported analysis output. Possibly mislabeled sequences have been marked.'
  end
end
