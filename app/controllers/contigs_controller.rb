class ContigsController < ApplicationController

  before_action :authenticate_user!, :except => [:edit, :index, :filter, :change_via_script, :compare_contigs, :as_fasq]

  skip_before_action :verify_authenticity_token

  before_action :set_contig, only: [:verify_next, :verify, :pde, :fasta, :fasta_trimmed, :fasta_raw, :overlap, :overlap_background, :show, :edit,\
   :update, :destroy]

  def externally_verified
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "imported") }
    end
  end


  def as_fasq

    contig_names=params[:contig_names]

    marker=params[:marker]

    mira=params[:mira]


    contig_names_array=contig_names.split

    fasq_str=""

    not_included_str="\n\n\n--------------------------------------------------------------------\n\n\n"

    contig_names_array.map do |contig_name|

      contig_name += "_#{marker}"

      # mk case insensitiv
      contig=Contig.where("name ILIKE ?", contig_name).first

      #ignore if not verified

      if contig

        if contig.verified

          if contig.imported
            not_included_str += "#{contig_name}: Externally verified -> no quality scores.\n"
          else
            begin
              fasq = contig.as_fasq(mira)
              fasq_str += fasq
            rescue
              not_included_str += "#{contig_name}: Unknown issue.\n"
            end
          end

        else
          not_included_str += "#{contig_name}: not verified.\n"
        end

      else
        not_included_str += "#{contig_name}: no record in GBOL5 Web App.\n"
      end

    end

    send_data(fasq_str+not_included_str, :filename => "fasq.txt", :type => "application/txt")

  end

  def compare_contigs
    contig_names=params[:contig_names]

    CompareContigs.perform_async(contig_names)

    send_data("Comparison started as background process, may take a minute or so. View results under http://gbol5.de/analysis_output\n", :filename => "msg.txt", :type => "application/txt")

  end

  def analysis_output
    redirect_to TxtUploader.last.uploaded_file.url
  end

  # for overwriting with externally edited / verified contigs in fas format (via .pde)
  def change_via_script

    filename=params[:filename]
    fastastring=params[:fastastring]

    # find matching contig based on 'filename' (first line, *not* starting with >) --> needs to be handed over via fas.string

    contig=identify_contig(filename)

    if contig

      output="Match found: #{contig.name}.\n"

      # mark contig as imported, assembled & verified
      contig.imported=true
      # contig.imported=false

      contig.assembled=true
      contig.verified=true
      contig.verified_by = 8 #User.first.id #unclear who did external verification, but won't be displayed anyway if imported
      contig.verified_at=Time.zone.now

      # destroy all current partial_cons
      contig.partial_cons.destroy_all

      #create a single new partial_con to be overwritten by imported stuff
      new_partial_con=contig.partial_cons.create


      # get aligned read sequences

      fas_seqs=fastastring.split(">")


      fas_seqs[1..-1].each do |fs|

        pair=fs.split("\n")

        # overwrite single reads (aligned - / manually corrected version (?) ) (> that do match general read pattern; use the exactly matching read or generate new)

        read_name=pair[0]

        # output+="name:\t#{read_name}\n"

        primer_read=identify_primer_read(read_name)

        if primer_read

          # output+="matched read: #{primer_read.name}\n"

          primer_read.aligned_seq=pair[1]

          #cannot use aligned qualities since not existing when imported from external alignment:
          primer_read.aligned_qualities=primer_read.qualities
          primer_read.overwritten=true

          # set read's use_for / assembled etc
          primer_read.used_for_con=true
          primer_read.assembled=true

          # todo: adjust trimmedReadStart etc. based on ???? in aligned_seq (though this is not technically correct due to alignemnt of ??? with gappy stretches in other reads)

          if primer_read.trimmedReadStart.nil?
            primer_read.trimmedReadStart=1
            primer_read.trimmedReadEnd=primer_read.sequence.length-1
          end

          primer_read.save

          new_partial_con.primer_reads << primer_read

        else
          # output+="no matching read - assumed to be consensus sequence.\n"

          # overwrite consensus (> that does not match general read pattern)

          new_partial_con.aligned_sequence=pair[1]
          new_partial_con.aligned_qualities=[]
          new_partial_con.save

          # generate marker sequence
          ms=MarkerSequence.find_or_create_by(:name => contig.name)
          ms.sequence = pair[1].gsub('-','')
          ms.sequence = ms.sequence.gsub('?','')
          ms.contigs << contig
          ms.marker = contig.marker
          ms.isolate = contig.isolate
          ms.save

        end

      end

      new_partial_con.save
      contig.save

    else

      output="No match found.\n"
    end

    send_data(output, :filename => "#{filename}.txt", :type => "application/txt")

  end

  def identify_primer_read(read_name)

    primer_read=PrimerRead.where("name ILIKE ?", "#{read_name}.scf").first

    if primer_read
      return primer_read
    else
      primer_read=PrimerRead.where("name ILIKE ?", "#{read_name}.ab1").first
      if primer_read
        return primer_read
      else
        return nil
      end
    end

    return nil

  end

  def identify_contig(c)

    contig_name=c[0...-4]

    #match found?
    contig = Contig.where("name ILIKE ?", contig_name).first

    if contig
      return contig
    else

      # retry by extracting one primer name and selecting the marker this primer is assigned to
      # extract primer_name

      regex= /^([A-Za-z0-9]+)_(.+)$/
      m=contig_name.match(regex)
      if m
        isolate_name=m[1]
        begin
          primer_names= m[2]
          primer_name=primer_names.split("_").last
          primer=Primer.where("name ILIKE ?", primer_name).first
          if primer
            marker=primer.marker
            if marker
              true_marker_name=marker.name
              true_contig_name=isolate_name+"_#{true_marker_name}"
              contig = Contig.where("name ILIKE ?", true_contig_name).first
              if contig
                return contig
              end
            end
          end
        rescue
        end
      else
      end
    end
  end

  # GET /contigs
  # GET /contigs.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "all") }
    end
  end

  def duplicates
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "duplicates") }
    end
  end

  def show_need_verify #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "need_verification") }
    end
  end


  def caryophyllales_need_verification #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "caryophyllales_need_verification") }
    end
  end

  def upload_caryo_matK_contigs
    CaryoContigExport.perform_async
    redirect_to caryophyllales_need_verification_contigs_path, notice: "Writing zip file to S3 in background. May take a minute or so."
  end

  def zip
    redirect_to ContigPdeUploader.last.uploaded_file.url
  end

  def caryophyllales_not_assembled #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "caryophyllales_not_assembled") }
    end
  end

  def caryophyllales_verified #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "caryophyllales_verified") }
    end
  end

  def festuca_need_verification #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "festuca_need_verification") }
    end
  end

  def festuca_not_assembled #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "festuca_not_assembled") }
    end
  end

  def festuca_verified #assembly finished according to app but still need manual check
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, "festuca_verified") }
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
    if @contig.verified_by or @contig.verified
      @contig.update(:verified_by => nil, :verified_at => nil, :verified => false)
      redirect_to edit_contig_path, notice: "Set to non-verified."
    else
      @contig.update(:verified_by => current_user.id, :verified_at => Time.now, :assembled => true, :verified => true)

      # generate / update markersequence
      # generate marker sequence
      ms=MarkerSequence.find_or_create_by(:name => @contig.name)
      partial_cons=@contig.partial_cons.first
      ms.sequence = partial_cons.aligned_sequence.gsub('-','')
      ms.sequence = ms.sequence.gsub('?','')
      ms.contigs << @contig
      ms.marker = @contig.marker
      ms.isolate = @contig.isolate
      ms.save

      redirect_to edit_contig_path, notice: "Verified & linked marker sequence updated."
    end
  end

  def verify_next

    @contig.update(:verified_by => current_user.id, :verified_at => Time.now, :assembled => true, :verified => true)

    # generate / update markersequence
    # generate marker sequence
    ms=MarkerSequence.find_or_create_by(:name => @contig.name)
    partial_cons=@contig.partial_cons.first
    ms.sequence = partial_cons.aligned_sequence.gsub('-','')
    ms.sequence = ms.sequence.gsub('?','')
    ms.contigs << @contig
    ms.marker = @contig.marker
    ms.isolate = @contig.isolate
    ms.save

    @next_contig=Contig.need_verification.first

    redirect_to edit_contig_path(@next_contig), notice: "Verified & linked marker sequence updated for #{@contig.name}. Showing #{@next_contig.name}."

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

    if @contig.primer_reads.where(:used_for_con => true).count <= 4
      @contig.auto_overlap
      msg='Assembly finished.'
    else
      ContigAssembly.perform_async(@contig.id)
      msg='Assembly started in background.'
    end

    redirect_to :back, notice: msg

  end

  def overlap_background
    ContigAssembly.perform_async(@contig.id)
    # @contig.auto_overlap
    redirect_to edit_contig_path, notice: 'Assembly started in background.'
  end

  # def pde_all
  #   Contig.all.each do |c|
  #     unless c.pde.nil?
  #       # send_data does not work with muliple
  #       #send_data(str, :filename => "#{c.name}.pde", :type => "application/txt")
  #
  #       cleaned_name=c.name.gsub('/', '_')
  #
  #       t=File.new("/Users/kai/Desktop/PDEexport/#{cleaned_name}.pde", "w+")
  #       t.write(c.pde)
  #       t.close
  #     end
  #   end
  #
  #   redirect_to contigs_path
  #
  # end

  def pde
    str=@contig.as_pde
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

    str=@contig.as_fas

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
    params.require(:contig).permit(:mira, :marker, :overlap_length, :allowed_mismatch_percent, :imported, :contig_names, :filename, :fastastring, :comment, :assembled, :name, :consensus, :marker_id, :isolate_id, :marker_sequence_id, :chromatograms, :term,
                                   :isolate_name, :verified)
  end

end