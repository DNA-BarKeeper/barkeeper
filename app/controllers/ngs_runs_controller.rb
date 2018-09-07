class NgsRunsController < ApplicationController
  include ProjectConcern
  load_and_authorize_resource

  before_action :set_ngs_run, only: [:show, :edit, :update, :destroy, :import]

  def index
    respond_to do |format|
      format.html
      format.json { render json: NgsRunDatatable.new(view_context, current_project_id) }
    end
  end

  def show
  end

  def new
    @ngs_run = NgsRun.new
  end

  def edit
  end

  def create
    @ngs_run = NgsRun.new(ngs_run_params)
    @ngs_run.add_project(current_project_id)

    params[:ngs_run][:tag_primer_map].each do |tpm|
      @ngs_run.tag_primer_maps.build(tag_primer_map: tpm)
    end

    respond_to do |format|
      if @ngs_run.save
        format.html { redirect_to ngs_runs_path, notice: 'NGS Run was successfully created.' }
        format.json { render :edit, status: :created, location: @ngs_run }
      else
        format.html { render :new }
        format.json { render json: @ngs_run.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:ngs_run].delete(:fastq) if params[:ngs_run][:fastq].blank?
    params[:ngs_run].delete(:set_tag_map) if params[:ngs_run][:set_tag_map].blank?

    if params[:ngs_run][:tag_primer_map].blank?
      params[:ngs_run].delete(:tag_primer_map)
    else
      params[:ngs_run][:tag_primer_map].each do |tpm|
        # Only add TPM if Package map is available or none was added before
        if !params[:ngs_run][:set_tag_map].blank? || @ngs_run.set_tag_map_file_name || @ngs_run.tag_primer_maps.size.zero?
          map = TagPrimerMap.create(tag_primer_map: tpm)
          @ngs_run.tag_primer_maps << map
        end
      end
    end

    @ngs_run.remove_tag_primer_maps(params[:delete_tag_primer_maps]) unless params[:delete_tag_primer_maps].blank?

    respond_to do |format|
      if @ngs_run.update(ngs_run_params)
        format.html { redirect_to edit_ngs_run_path(@ngs_run), notice: 'NGS Run was successfully updated.' }
        format.json { render :index, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @ngs_run.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ngs_run.destroy
    respond_to do |format|
      format.html { redirect_to ngs_runs_url, notice: 'NGS Run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    if @ngs_run.check_fastq
      if @ngs_run.check_tag_primer_maps
        isolates_not_in_db = @ngs_run.samples_exist
        if isolates_not_in_db.blank?
          @ngs_run.import
          redirect_to ngs_runs_path, notice: 'NGS Run data imported.'
        else
          redirect_back(fallback_location: ngs_runs_path,
                        alert: "Please create database entries for the following sample IDs before starting the import: #{isolates_not_in_db.join(', ')}")
        end
      else
        redirect_back(fallback_location: ngs_runs_path, alert: 'Please make sure you uploaded as many properly formatted tag primer maps as stated in the packages fasta.')
      end
    else
      redirect_back(fallback_location: ngs_runs_path, alert: 'Please make sure you uploaded a properly formatted FastQ.')
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ngs_run
    @ngs_run = NgsRun.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ngs_run_params
    params.require(:ngs_run).permit(:name, :primer_mismatches, :quality_threshold, :tag_mismates, :fastq, :set_tag_map, :higher_order_taxon_id, :delete_fastq, :delete_set_tag_map)
  end
end
