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
    @contig_search = ContigSearch.new(contig_search_params)

    respond_to do |format|
      if @contig_search.save
        if user_signed_in?
          @contig_search.update(user_id: current_user.id)
          @contig_search.update(project_id: current_user.default_project_id)
        end

        format.html { redirect_to @contig_search }
        format.json { render :show, status: :created, location: @contig_search }
      else
        format.html { render :new }
        format.json { render json: @contig_search.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @contig_search = ContigSearch.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: ContigSearchResultDatatable.new(view_context, params[:id]) }
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @contig_search.update(contig_search_params)
        format.html { redirect_to contig_search_path(@contig_search), notice: 'Search parameters were successfully updated.' }
        format.json { render :show, status: :ok, location: @contig_search }
      else
        format.html { render :edit }
        format.json { render json: @contig_search.errors, status: :unprocessable_entity }
      end
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
    send_data(ContigSearch.pde(@contig_search.contigs.includes(:partial_cons, isolate: [individual: :taxon]), add_reads: false), filename: "#{file_name}.pde", type: 'application/txt')
  end

  def export_results_as_zip
    @contig_search = ContigSearch.find(params[:contig_search_id])

    ContigSearchResultExport.perform_async(params[:contig_search_id])
    redirect_to @contig_search,
                notice: "The result archive file is being written to the server in the background. This may take some time. Download with 'Download result archive' button."
  end

  def download_results
    require 'open-uri'

    @contig_search = ContigSearch.find(params[:contig_search_id])

    if @contig_search.search_result_archive.attached?
      archive = @contig_search.search_result_archive

      begin
        send_data(archive.blob.download,
                  filename: @contig_search.search_result_archive.filename,
                  type: 'application/zip')
      rescue OpenURI::HTTPError # Results archive could not be found on server
        redirect_to @contig_search,
                    alert: 'The result archive file could not be opened. Please try to create it again or contact an administrator if the issue persists.'
      end
    else
      flash[:warning] = 'There is no search result archive available. Please create it on the server first (this may take some time to finish).' # Warning cannot be set directly in redirect
      redirect_to @contig_search
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def contig_search_params
    params.require(:contig_search).permit(:title, :assembled, :has_warnings, :has_issues, :marker, :max_age, :max_update,
                                          :min_age, :min_update, :name, :taxon, :specimen, :verified, :verified_by,
                                          :project_id, :search_result_archive)
  end
end
