class MarkerSequencesController < ApplicationController

  before_filter :authenticate_user!, :except => [:filter]

  before_action :set_marker_sequence, only: [:show, :edit, :update, :destroy]

  # GET /marker_sequences
  # GET /marker_sequences.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: MarkerSequenceDatatable.new(view_context)}
    end

  end

  def filter
    @marker_sequences = MarkerSequence.where('name ILIKE ?', "%#{params[:term]}%").order(:name)
    render json: @marker_sequences.map(&:name)
  end

  # GET /marker_sequences/1
  # GET /marker_sequences/1.json
  def show
  end

  # GET /marker_sequences/new
  def new
    @marker_sequence = MarkerSequence.new
  end

  # GET /marker_sequences/1/edit
  def edit
  end

  # POST /marker_sequences
  # POST /marker_sequences.json
  def create
    @marker_sequence = MarkerSequence.new(marker_sequence_params)
    @marker_sequence.save

    if @marker_sequence.name.empty?
        @marker_sequence.generate_name
    end

    respond_to do |format|
      if @marker_sequence.save
        format.html { redirect_to marker_sequences_path, notice: 'Marker sequence was successfully created.' }
        format.json { render :show, status: :created, location: @marker_sequence }
      else
        format.html { render :new }
        format.json { render json: @marker_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marker_sequences/1
  # PATCH/PUT /marker_sequences/1.json
  def update

    @marker_sequence.update(marker_sequence_params)

    if @marker_sequence.name.empty?
      @marker_sequence.generate_name
    end

    redirect_to edit_marker_sequence_path(@marker_sequence), notice: 'Marker sequence was successfully updated.'

  end

  # DELETE /marker_sequences/1
  # DELETE /marker_sequences/1.json
  def destroy
    @marker_sequence.destroy
    respond_to do |format|
      format.html { redirect_to marker_sequences_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_marker_sequence
    @marker_sequence = MarkerSequence.includes(:isolate => :individual).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def marker_sequence_params
    params.require(:marker_sequence).permit(:genbank, :name, :sequence, :isolate_id, :marker_id, :contig_id, :isolate_lab_nr)
  end
end
