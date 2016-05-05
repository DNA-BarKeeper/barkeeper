class ContigsController < ApplicationController

  before_filter :authenticate_user!, :except => [:edit, :index, :filter, :change_via_script, :compare_contigs]

  skip_before_action :verify_authenticity_token

  before_action :set_contig, only: [:verify, :pde, :fasta, :fasta_trimmed, :fasta_raw, :overlap, :overlap_background, :show, :edit,\
   :update, :destroy]

  def compare_contigs
    contig_names=params[:contig_names]
    no_match_list="No matches found for:\n\n"
    match_list="\n\nMatches found for:\n\n"

    # parse contig_names string into array
    contig_names_array=contig_names.split

    #loop over contig_names array
    contig_names_array.each do |c|

      contig_name=c[0...-4]

      #match found?
      if contig=Contig.find_by_name(contig_name)
        match_list+="#{c}"
        if contig.verified
          match_list+="\tverified"
        end
        match_list+="\n"
      else
        # extract marker-name,~
        regex= /(^[A-Za-z0-9]+)_(.+)/
        m=contig_name.match(regex)
        begin
          alt_marker_name= m[2]
          # retry with alt.marker_name
          if marker=Marker.find_by_alt_name(alt_marker_name)
            true_marker_name=marker.name
            true_contig_name=m[1]+"_#{true_marker_name}"
            if contig=Contig.find_by_name(true_contig_name)
              match_list+="#{c} (found as #{true_contig_name})"
              if contig.verified
                match_list+="\tverified"
              end
              match_list+="\n"
            else
              no_match_list+="#{c}\n"
            end
          else
            no_match_list+="#{c}\n"
          end
        rescue
          no_match_list+="#{c}\n"
        end
      end
    end

    no_match_list+=match_list

    send_data(no_match_list, :filename => "no_match_list.txt", :type => "application/txt")
  end

  def change_via_script

    filename=params[:filename]
    fastastring=params[:fastastring]

    # find matching contig based on 'filename' (first line, *not* starting with >) --> needs to be handed over via fas.string

    contig=identify_contig(filename)

    # overwrite consensus (> that does not match general read pattern)
    # overwrite single reads (aligned - / manually corrected version (?) ) (> that do match general read pattern; use the exactly matching read or generate new)
    # [ Clip reads - Use single read extension in fasta-contigs to clip primer reads accordingly in db ]
    # set read's use_for / assembled etc
    # mark contig as assembled & verified
    # add comment 'imported' to contig
    # generate marker sequence

    # render nothing: true
    fastastring+=filename
    send_data(fastastring, :filename => "#{filename}.txt", :type => "application/txt")

  end

  def identify_contig(filename)
    matches=Contig.where(:name => filename).count
    if  matches > 0
      contig = Contig.where(:name => filename).first
    else
      #   decompose name
    end
    return contig
  end

  # GET /contigs
  # GET /contigs.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, false) }
    end
  end

  def duplicates

  end

  def show_need_verify #assembly finished according to app but still need manual check
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
      @contig.update(:verified_by => current_user.id, :verified_at => Time.now, :assembled => true)
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
    @contig = Contig.includes(:isolate =>  :individual).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contig_params
    params.require(:contig).permit(:contig_names, :filename, :fastastring, :comment, :assembled, :name, :consensus, :marker_id, :isolate_id, :marker_sequence_id, :chromatograms, :term,
                                   :isolate_name, :verified)
  end
end