class ContigsController < ApplicationController

  before_filter :authenticate_user!, :except => [:edit, :index, :filter]

  before_action :set_contig, only: [:verify, :pde, :fasta, :fasta_trimmed, :fasta_raw, :overlap, :overlap_background, :show, :edit, :update, :destroy]

  # GET /contigs
  # GET /contigs.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, false) }
    end
  end

  def show_need_verify #assembled according to app but need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, true) }
    end
  end

  def assemble_all
    Contig.where(:assembled => false).each do |c|
      ContigAssembly.perform_async(c.id)
    end
    redirect_to contigs_path, notice: "Assembly for #{Contig.where(:assembled => false).count} contigs started in background."
  end

  def filter
    @contigs = Contig.order(:name).where("name like ?", "%#{params[:term]}%")
    render json: @contigs.map(&:name)
  end

  def verify
    if @contig.verified_by
      @contig.update(:verified_by => nil, :verified_at => nil)
      redirect_to edit_contig_path, notice: "Set to non-verified."
    else
      @contig.update(:verified_by => current_user.id, :verified_at => Time.now)
      redirect_to edit_contig_path, notice: "Verified."
    end
  end




  # GET /contigs/1
  # GET /contigs/1.json
  def show
  end

  # GET /contigs/new
  def new
    @contig = Contig.new
  end

  # GET /contigs/1/edit
  def edit
  end

  # POST /contigs
  # POST /contigs.json
  def create
    @contig = Contig.new(contig_params)

    respond_to do |format|
      if @contig.save

        format.html { redirect_to @contig, notice: 'Contig was successfully created.' }
        format.json { render :show, status: :created, location: @contig }
      else
        format.html { render :new }
        format.json { render json: @contig.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contigs/1
  # PATCH/PUT /contigs/1.json
  def update
    respond_to do |format|
      if @contig.update(contig_params)
        format.html {
          Issue.create(:title => "Contig updated by #{current_user.name}", :contig_id => @contig.id)
          redirect_to edit_contig_path(@contig), notice: 'Contig was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @contig }
      else
        format.html { render :edit }
        format.json { render json: @contig.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contigs/1
  # DELETE /contigs/1.json
  def destroy
    @contig.destroy
    respond_to do |format|
      format.html { redirect_to contigs_url }
      format.json { head :no_content }
    end
  end


  def overlap

    @contig.auto_overlap
    redirect_to edit_contig_path, notice: 'Assembly finished.'

  end

  def overlap_background

    ContigAssembly.perform_async(@contig.id)
    # @contig.auto_overlap
    redirect_to edit_contig_path, notice: 'Assembly started in background.'

  end

  def pde_all
    Contig.all.each do |c|

      unless c.pde.nil?
        # send_data does not work with muliple
        #send_data(str, :filename => "#{c.name}.pde", :type => "application/txt")

        cleaned_name=c.name.gsub('/', '_')

        t=File.new("/Users/kai/Desktop/PDEexport/#{cleaned_name}.pde", "w+")
        t.write(c.pde)
        t.close

      end
    end

    redirect_to contigs_path
  end

  def pde
    str=@contig.pde
    # send_data str
    send_data(str, :filename => "#{@contig.name}.pde", :type => "application/txt")
  end


  def fasta
    # old v. : inline computation
    # used_reads = @c.primer_reads.where("used_for_con = ? AND assembled = ?", true, true).order('position')
    # str=""
    # used_reads.each  do |r|
    #   str= str + ">#{r.name}\n#{r.aligned_seq}\n"
    # end

    # new version: get from db:

    str=@contig.fas

    # send_data str
    send_data(str, :filename => "#{@contig.name}.fas", :type => "application/txt")
  end

  def fasta_trimmed
    used_reads = @contig.primer_reads.where("used_for_con = ? AND assembled = ?", true, true).order('position')
    str=""
    used_reads.each  do |r|
      str= str + ">#{r.name}\n#{r.trimmed_seq}\n"
    end

    # send_data str
    send_data(str, :filename => "#{@contig.name}.fas", :type => "application/txt")
  end

  def fasta_raw
    used_reads = @contig.primer_reads.where("used_for_con = ? AND assembled = ?", true, true).order('position')
    str=""
    used_reads.each  do |r|
      str= str + ">#{r.name}\n#{r.sequence}\n"
    end

    # send_data str
    send_data(str, :filename => "#{@contig.name}.fas", :type => "application/txt")
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contig
    @contig = Contig.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contig_params
    params.require(:contig).permit(:assembled, :name, :consensus, :marker_id, :isolate_id, :marker_sequence_id, :chromatograms, :term,
                                   :isolate_name, :verified)
  end
end