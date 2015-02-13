class ContigsController < ApplicationController

  before_filter :authenticate_user!

  before_action :set_contig, only: [:pde, :fasta, :fasta_trimmed, :fasta_raw, :overlap, :show, :edit, :update, :destroy]

  # GET /contigs
  # GET /contigs.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context) }
    end
  end

  def assemble
    Contig.where(:assembled => false).each do |c|
      c.auto_overlap
    end
    redirect_to contigs_path, notice: "Assembled. Check 'Project->Issues' for problems that may have occurred."
  end

  def filter
    @contigs = Contig.order(:name).where("name like ?", "%#{params[:term]}%")
    render json: @contigs.map(&:name)
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
        format.html { redirect_to edit_contig_path(@contig), notice: 'Contig was successfully updated.' }
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
    reads = @contig.primer_reads.where(:used_for_con => true)
    #test how many
    if reads.length > 10
      redirect_to edit_contig_path, alert: 'Currently no more than 10 reads allowed for assembly.'
      return
    elsif reads.length < 2
      redirect_to edit_contig_path, alert: 'Need >1 reads for overlap.'
      return
    else


      # s1= @c.primer_reads.where(:used_for_con => true)[0]
      # s2= @c.primer_reads.where(:used_for_con => true)[1]
      # seq1 = s1.trimmed_seq
      # seq2 = s2.trimmed_seq

      # if alignedSeqs=@c.overlap(seq1, seq2)

      @contig.auto_overlap

      # s1.aligned_seq=alignedSeqs[0]
      # s2.aligned_seq=alignedSeqs[1]
      #
      # s1.update(:aligned_seq => alignedSeqs[0])
      # s2.update(:aligned_seq => alignedSeqs[1])


      # currently tried within controller:
      # for t in 0...reads.length
      #   reads[t].update(:aligned_seq => alignedSeqs[t])
      # end

      # if alignedSeqs[3]==1
      #   redirect_to edit_contig_path, notice: alignedSeqs[2]
      # else
      #   redirect_to edit_contig_path, alert: alignedSeqs[2]
      # end

      redirect_to edit_contig_path, notice: 'Assembled. Check Project>Issues for potential errors.'

    end
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
                                   :isolate_name)
  end
end