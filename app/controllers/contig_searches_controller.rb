# frozen_string_literal: true

class ContigSearchesController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: ContigSearchDatatable.new(view_context, current_user.id) }
    end
  end

  def new
    @contig_search = ContigSearch.new
  end

  def create
    @contig_search = ContigSearch.create!(contig_search_params)

    @contig_search.update(user_id: current_user.id)
    @contig_search.update(project_id: current_user.default_project_id)

    redirect_to @contig_search
  end

  def show
    @contig_search = ContigSearch.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: ContigSearchResultDatatable.new(view_context, params[:id]) }
    end
  end

  def destroy
    @contig_search.destroy
    respond_to do |format|
      format.html { redirect_to contig_searches_path, notice: 'Contig search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_all
    @contig_search = ContigSearch.find(params[:contig_search_id])
    @contig_search.contigs.destroy_all

    respond_to do |format|
      format.html { redirect_to contig_search_path(@contig_search), notice: 'All contigs and associated records were successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export_as_pde
    @contig_search = ContigSearch.find(params[:contig_search_id])
    file_name = @contig_search.title.empty? ? "contig_search_#{@contig_search.created_at}" : @contig_search.title
    send_data(ContigSearch.pde(@contig_search.contigs.includes(:partial_cons, isolate: [individual: :species]), add_reads: false), filename: "#{file_name}.pde", type: 'application/txt')
  end

  # TODO: Unfinished feature
  # def export_results_as_zip
  #   @contig_search = ContigSearch.find(params[:contig_search_id])
  #
  #   ContigSearchResultExport.perform_async(@contig_search)
  #   redirect_to @contig_search, notice: "Writing zip file to S3 in background. May take a minute or so. Download with 'Download results' button."
  # end
  #
  # def download_results
  #   @contig_search = ContigSearch.find(params[:contig_search_id])
  #   send_data(File.read(@contig_search.search_result_archive.url), :filename => @contig_search.search_result_archive_file_name, :type => "application/zip")
  # end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def contig_search_params
    params.require(:contig_search).permit(:title, :assembled, :has_warnings, :family, :marker, :max_age, :max_update, :min_age, :min_update, :name, :order, :species, :specimen, :verified, :verified_by, :project_id, :search_result_archive)
  end
end
