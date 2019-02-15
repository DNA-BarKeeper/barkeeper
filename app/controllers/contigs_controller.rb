# frozen_string_literal: true

class ContigsController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  skip_before_action :verify_authenticity_token

  before_action :set_contig, only: %i[verify_next verify pde fasta fasta_trimmed fasta_raw overlap overlap_background show edit
                                      update destroy]

  # GET /contigs
  # GET /contigs.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, '', current_project_id) }
    end
  end

  def duplicates
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, 'duplicates', current_project_id) }
    end
  end

  def externally_verified
    respond_to do |format|
      format.html
      format.json { render json: ContigDatatable.new(view_context, 'imported', current_project_id) }
    end
  end

  def filter
    @contigs = Contig.in_project(current_project_id).order(:name).where('name ilike ?', "%#{params[:term]}%").limit(100)
    size = Contig.in_project(current_project_id).order(:name).where('name ilike ?', "%#{params[:term]}%").size

    if size > 100
      message = "and #{size} more..."
      render json: @contigs.map(&:name).push(message)
    else
      render json: @contigs.map(&:name)
    end
  end

  # GET /contigs/1
  # GET /contigs/1.json
  def show; end

  # GET /contigs/new
  def new
    @contig = Contig.new
  end

  # GET /contigs/1/edit
  def edit; end

  # POST /contigs
  # POST /contigs.json
  def create
    @contig = Contig.new(contig_params)
    @contig.add_project(current_project_id)

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
        format.html do
          issue = Issue.create(title: "Contig updated by #{current_user.name}", contig_id: @contig.id)
          issue.add_projects(@contig.projects.pluck(:id))
          issue.save
          redirect_back(fallback_location: edit_contig_path(@contig), notice: 'Contig was successfully updated.')
        end
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
      format.html { redirect_to contigs_path, notice: 'Contig and associated reads and marker sequence were successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def compare_contigs
    contig_names = params[:contig_names]

    CompareContigs.perform_async(contig_names)

    send_data("Comparison started as background process, may take a minute or so. View results under http://gbol5.de/analysis_output\n", filename: 'msg.txt', type: 'application/txt')
  end

  def analysis_output
    redirect_to TxtUploader.last.uploaded_file.url
  end

  # for overwriting with externally edited / verified contigs in fas format (via .pde)
  def change_via_script
    filename = params[:filename]
    fastastring = params[:fastastring]

    # find matching contig based on 'filename' (first line, *not* starting with >) --> needs to be handed over via fas.string

    contig = identify_contig(filename)

    if contig

      output = "Match found: #{contig.name}.\n"

      # mark contig as imported, assembled & verified
      contig.imported = true
      # contig.imported=false

      contig.assembled = true
      contig.verified = true
      contig.verified_by = 8 # User.first.id #unclear who did external verification, but won't be displayed anyway if imported
      contig.verified_at = Time.zone.now

      # destroy all current partial_cons
      contig.partial_cons.destroy_all

      # create a single new partial_con to be overwritten by imported stuff
      new_partial_con = contig.partial_cons.create

      # get aligned read sequences

      fas_seqs = fastastring.split('>')

      fas_seqs[1..-1].each do |fs|
        pair = fs.split("\n")

        # overwrite single reads (aligned - / manually corrected version (?) ) (> that do match general read pattern; use the exactly matching read or generate new)

        read_name = pair[0]

        # output+="name:\t#{read_name}\n"

        primer_read = identify_primer_read(read_name)

        if primer_read

          # output+="matched read: #{primer_read.name}\n"

          primer_read.aligned_seq = pair[1]

          # cannot use aligned qualities since not existing when imported from external alignment:
          primer_read.aligned_qualities = primer_read.qualities
          primer_read.overwritten = true

          # set read's use_for / assembled etc
          primer_read.used_for_con = true
          primer_read.assembled = true

          # TODO: adjust trimmedReadStart etc. based on ???? in aligned_seq (though this is not technically correct due to alignemnt of ??? with gappy stretches in other reads)

          if primer_read.trimmedReadStart.nil?
            primer_read.trimmedReadStart = 1
            primer_read.trimmedReadEnd = primer_read.sequence.length - 1
          end

          primer_read.save

          new_partial_con.primer_reads << primer_read

        else
          # output+="no matching read - assumed to be consensus sequence.\n"

          # overwrite consensus (> that does not match general read pattern)

          new_partial_con.aligned_sequence = pair[1]
          new_partial_con.aligned_qualities = []
          new_partial_con.save

          # generate marker sequence
          ms = MarkerSequence.find_or_create_by(name: contig.name) # TODO is it used? Add project if so
          ms.sequence = pair[1].delete('-')
          ms.sequence = ms.sequence.delete('?')
          ms.contigs << contig
          ms.marker = contig.marker
          ms.isolate = contig.isolate
          ms.save

        end
      end

      new_partial_con.save
      contig.save

    else

      output = "No match found.\n"
    end

    send_data(output, filename: "#{filename}.txt", type: 'application/txt')
  end

  def identify_primer_read(read_name)
    primer_read = PrimerRead.where('name ILIKE ?', "#{read_name}.scf").first

    if primer_read
      return primer_read
    else
      primer_read = PrimerRead.where('name ILIKE ?', "#{read_name}.ab1").first
      if primer_read
        return primer_read
      else
        return nil
      end
    end

    nil
  end

  def identify_contig(c)
    contig_name = c[0...-4]

    # match found?
    contig = Contig.in_project(current_project_id).where('name ILIKE ?', contig_name).first

    if contig
      return contig if contig
    else

      # retry by extracting one primer name and selecting the marker this primer is assigned to
      # extract primer_name

      regex = /^([A-Za-z0-9]+)_(.+)$/
      m = contig_name.match(regex)
      if m
        isolate_name = m[1]
        begin
          primer_names = m[2]
          primer_name = primer_names.split('_').last
          primer = Primer.where('name ILIKE ?', primer_name).first
          if primer
            marker = primer.marker
            if marker
              true_marker_name = marker.name
              true_contig_name = isolate_name + "_#{true_marker_name}"
              contig = Contig.in_project(current_project_id).where('name ILIKE ?', true_contig_name).first
              return contig if contig
            end
          end
        rescue StandardError
        end
      end
    end
  end

  def assemble_all
    contigs = Contig.in_project(current_project_id).not_assembled

    contigs.each do |c|
      ContigAssembly.perform_async(c.id)
    end

    redirect_to contigs_path, notice: "Assembly for #{contigs.size} contigs started in background."
  end

  def verify
    if @contig.verified_by || @contig.verified
      @contig.update(verified_by: nil, verified_at: nil, verified: false)
      redirect_to edit_contig_path, notice: 'Set to non-verified.'
    else
      @contig.update(verified_by: current_user.id, verified_at: Time.now, assembled: true, verified: true)

      # generate / update marker sequence
      ms = MarkerSequence.find_or_create_by(name: @contig.name)
      partial_cons = @contig.partial_cons.first
      ms.sequence = partial_cons.aligned_sequence.delete('-')
      ms.sequence = ms.sequence.delete('?')
      ms.contigs << @contig
      ms.marker = @contig.marker
      ms.isolate = @contig.isolate
      ms.add_projects(@contig.projects.pluck(:id))
      ms.save

      redirect_to edit_contig_path, notice: 'Verified & linked marker sequence updated.'
    end
  end

  def verify_next
    @contig.update(verified_by: current_user.id, verified_at: Time.now, assembled: true, verified: true)

    # Generate or update MarkerSequence
    ms = MarkerSequence.find_or_create_by(name: @contig.name)
    partial_cons = @contig.partial_cons.first
    ms.sequence = partial_cons.aligned_sequence.delete('-')
    ms.sequence = ms.sequence.delete('?')
    ms.contigs << @contig
    ms.marker = @contig.marker
    ms.isolate = @contig.isolate
    ms.add_projects(@contig.projects.pluck(:id))
    ms.save

    @next_contig = Contig.in_project(current_project_id).need_verification.first

    redirect_to edit_contig_path(@next_contig), notice: "Verified & linked marker sequence updated for #{@contig.name}. Showing #{@next_contig.name}."
  end

  def overlap
    if @contig.primer_reads.where(used_for_con: true).count <= 4
      @contig.auto_overlap
      msg = 'Assembly finished.'
    else
      ContigAssembly.perform_async(@contig.id)
      msg = 'Assembly started in background.'
    end

    redirect_back(fallback_location: contigs_path, notice: msg)
  end

  def overlap_background
    ContigAssembly.perform_async(@contig.id)
    # @contig.auto_overlap
    redirect_to edit_contig_path, notice: 'Assembly started in background.'
  end

  def pde
    pde = Contig.pde([@contig], add_reads: true)
    send_data(pde, filename: "#{@contig.name}.pde", type: 'application/txt')
  end

  def fasta
    fasta = Contig.fasta([@contig], mode: 'assembled')
    send_data(fasta, filename: "#{@contig.name}.fas", type: 'application/txt')
  end

  def fasta_trimmed
    fasta = Contig.fasta([@contig], mode: 'trimmed')
    send_data(fasta, filename: "#{@contig.name}_trimmed.fas", type: 'application/txt')
  end

  def fasta_raw
    fasta = Contig.fasta([@contig], mode: 'raw')
    send_data(fasta, filename: "#{@contig.name}_raw.fas", type: 'application/txt')
  end

  # TODO: Not used anywhere yet, talk to Susi about her needs for this export
  def fastq
    use_mira = params[:mira] == 1 || params[:mira] == '1'

    contig_names = params[:contig_names].split.collect { |name| name + "_#{params[:marker]}" }
    contigs = Contig.in_project(current_project_id).where('name ilike any (array[?])', contig_names)

    fastq = Contig.fastq(contigs.where(verified: true, imported: false), use_mira)

    send_data(fastq, filename: 'contigs.fastq', type: 'application/txt')
  end

  # Is used by API endpoint to compare sequences to PacBio data
  def as_fasq
    contig_names = params[:contig_names]

    marker = params[:marker]

    mira = params[:mira]

    contig_names_array = contig_names.split

    fasq_str = +''

    not_included_str = +"\n\n\n--------------------------------------------------------------------\n\n\n"

    contig_names_array.map do |contig_name|
      contig_name += "_#{marker}"

      # mk case insensitive
      contig = Contig.in_project(current_project_id).where('contigs.name ILIKE ?', contig_name).first

      # ignore if not verified
      if contig
        if contig.verified
          if contig.imported
            not_included_str += "#{contig_name}: Externally verified -> no quality scores.\n"
          else
            begin
              fasq = contig.as_fasq(mira)
              fasq_str += fasq
            rescue StandardError
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

    send_data(fasq_str + not_included_str, filename: 'fasq.txt', type: 'application/txt')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contig
    @contig = Contig.includes(isolate: :individual).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # TODO mira and marker only used by fastq export
  # TODO contig_names is only used by contig compare feature
  # TODO filename and fastastring are only used by change via script action
  # TODO: isolate_name used in form for contig, but cant that be done via id?
  def contig_params
    params.require(:contig).permit(:mira, :marker, :overlap_length, :allowed_mismatch_percent, :imported, :contig_names,
                                   :filename, :fastastring, :comment, :assembled, :name, :consensus, :marker_id,
                                   :isolate_id, :marker_sequence_id, :term, :isolate_name, :verified,
                                   project_ids: [])
  end
end
