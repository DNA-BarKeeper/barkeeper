class ContigSearchesController < ApplicationController
  def new
    @contig_search = ContigSearch.new
  end

  def create
    params = contig_search_params[:contig_search]
    @contig_search = ContigSearch.create!(params)

    puts "params #{params}"

    @contig_search.update(
        :min_age => (Date.new params['min_age'['year']].to_i, params['min_age'['month']].to_i, params['min_age'['day']].to_i),
        :max_age => (Date.new params['max_age'['year']].to_i, params['max_age'['month']].to_i, params['max_age'['day']].to_i),
        :min_updated => (Date.new params['min_updated'['year']].to_i, params['min_updated'['month']].to_i, params['min_updated'['day']].to_i),
        :min_updated => (Date.new params['min_updated'['year']].to_i, params['min_updated'['month']].to_i, params['min_updated'['day']].to_i)
    )

    redirect_to @contig_search
  end

  def show
    @contig_search = ContigSearch.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: ContigSearchDatatable.new(view_context, params[:id]) }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def contig_search_params
    params.require(:contig_search).permit(:assembled, :unassembled, :family, :marker_id, :max_age, :max_update, :min_age, :min_update, :name, :order_id, :species, :specimen, :verified, :unverified)
  end
end
