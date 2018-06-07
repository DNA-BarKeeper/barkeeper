class MarkerSequenceSearchesController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: MarkerSequenceSearchDatatable.new(view_context, current_user.id) }
    end
  end

  def new
    @marker_sequence_search = MarkerSequenceSearch.new
  end

  def create
    @marker_sequence_search = MarkerSequenceSearch.create!(marker_sequence_search_params)

    @marker_sequence_search.update(:user_id => current_user.id)
    @marker_sequence_search.update(:project_id => current_user.default_project_id)

    redirect_to @marker_sequence_search
  end

  def show
    @marker_sequence_search = MarkerSequenceSearch.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: MarkerSequenceSearchResultDatatable.new(view_context, params[:id]) }
    end
  end

  def destroy
    @marker_sequence_search.destroy
    respond_to do |format|
      format.html { redirect_to marker_sequence_searches_path, notice: 'Marker sequence search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export_as_fasta
    @marker_sequence_search = MarkerSequenceSearch.find(params[:marker_sequence_search_id])
    file_name = @marker_sequence_search.title.empty? ? "marker_sequence_search_#{@marker_sequence_search.created_at}" : @marker_sequence_search.title
    send_data(@marker_sequence_search.as_fasta, :filename => "#{file_name}.fasta", :type => "application/txt")
  end

  def export_taxon_file
    @marker_sequence_search = MarkerSequenceSearch.find(params[:marker_sequence_search_id])
    file_name = @marker_sequence_search.title.empty? ? "marker_sequence_search_#{@marker_sequence_search.created_at}" : @marker_sequence_search.title
    send_data(@marker_sequence_search.taxon_file, :filename => "#{file_name}.tax", :type => "application/txt")
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def marker_sequence_search_params
    params.require(:marker_sequence_search).permit(:title, :name, :has_species, :marker, :order, :species, :specimen, :family, :verified, :max_length, :min_length, :project_id)
  end
end
