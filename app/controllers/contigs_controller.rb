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

class ContigsController < ApplicationController
  include ProjectConcern

  load_and_authorize_resource

  http_basic_authenticate_with name: ENV['API_USER_NAME'], password: ENV['API_PASSWORD'], only: [:as_fasq, :change_via_script]

  skip_before_action :verify_authenticity_token, only: [:as_fasq, :change_via_script]

  before_action :set_contig, only: %i[verify_next verify pde fasta fasta_trimmed fasta_raw overlap overlap_background show edit
                                      update destroy]

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
    @contigs = Contig.in_project(current_project_id).order(:name).where('contigs.name ilike ?', "%#{params[:term]}%")

    if params[:name_only] == '1'
      render json: @contigs.map{ |contig| {:id=> contig.name, :name => contig.name }}
    else
      render json: @contigs.map{ |contig| {:id=> contig.id, :name => contig.name }}
    end
  end

  def show; end

  def new
    @contig = Contig.new
  end

  def edit; end

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

  def update
    respond_to do |format|
      if @contig.update(contig_params)
        format.html do
          Issue.create(title: "Contig updated by #{current_user.name}", contig_id: @contig.id)
          redirect_back(fallback_location: edit_contig_path(@contig), notice: 'Contig was successfully updated.')
        end
        format.json { render :show, status: :ok, location: @contig }
      else
        format.html { render :edit }
        format.json { render json: @contig.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contig.destroy

    respond_to do |format|
      format.html { redirect_to contigs_path, notice: 'Contig and associated reads and marker sequence were successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def import
    #TODO: Allow import of multiple files, especially when Bonn PDEs should be re-uploaded
    file = params[:file]
    verified_by = params[:contig][:verified_by]
    marker = params[:contig][:marker_id]

    if file && verified_by && marker
      warning = Contig.import(file, verified_by, marker, current_project_id)
      if !warning.empty?
        redirect_to contigs_path,
                    notice: "Finished. The following #{warning.size} contigs were not imported, since read data was already present: #{warning.join(', ')}"
      else
        redirect_to contigs_path, notice: 'Imported.'
        end
    else
      redirect_to contigs_path, notice: 'Please select a file, the user who verified the contained sequences and the marker they belong to.'
    end
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

        # overwrite single reads (aligned - / manually corrected version (?) )
        # (> that do match general read pattern; use the exactly matching read or generate new)

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

          # TODO: adjust trimmedReadStart etc. based on ???? in aligned_seq
          # (though this is not technically correct due to alignment of ??? with gappy stretches in other reads)

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

    redirect_to contigs_path, notice: "Assembly for #{contigs.size} contigs started in the background."
  end

  def verify
    if @contig.verified_by || @contig.verified
      @contig.update(verified_by: nil, verified_at: nil, verified: false)
      redirect_to edit_contig_path, notice: 'Contig set to non-verified.'
    else
      @contig.verify_contig(current_user)

      redirect_to edit_contig_path, notice: 'Verified and updated the linked marker sequence.'
    end
  end

  def verify_next
    @contig.verify_contig(current_user)

    @next_contig = Contig.in_project(current_project_id).need_verification.first

    if @next_contig
      redirect_to edit_contig_path(@next_contig), notice: "Verified and updated the linked marker sequence for #{@contig.name}. Showing #{@next_contig.name}."
    else
      redirect_to contigs_path, notice: "All assembled contigs in your current project are verified."
    end
  end

  def overlap
    if @contig.primer_reads.size < 1
      msg = 'No reads are available for assembly.'
    elsif @contig.primer_reads.where(used_for_con: true).count <= 4
      @contig.auto_overlap
      msg = 'Assembly finished.'
    else
      ContigAssembly.perform_async(@contig.id)
      msg = 'Assembly started in the background.'
    end

    redirect_back(fallback_location: contigs_path, notice: msg)
  end

  def overlap_background
    ContigAssembly.perform_async(@contig.id)
    # @contig.auto_overlap
    redirect_to edit_contig_path, notice: 'Assembly started in the background.'
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

    verified = true if (params[:verified] == '1') || (params[:verified] == 1)

    contig_names_array = contig_names.split

    fasq_str = +''

    not_included_str = +"\n\n\n--------------------------------------------------------------------\n\n\n"

    contig_names_array.map do |contig_name|
      contig_name += "_#{marker}"

      # mk case insensitive
      contig = Contig.in_project(current_project_id).where('contigs.name ILIKE ?', contig_name).first

      # ignore if not verified
      if contig
        if contig.verified || !verified
          begin
            fasq = contig.as_fasq(mira)
            fasq_str += fasq
          rescue StandardError
            not_included_str += "#{contig_name}: A problem occurred during FASTQ export.\n"
          end
        else
          not_included_str += "#{contig_name}: not verified.\n"
        end
      else
        not_included_str += "#{contig_name}: no record in BarKeeper web app.\n"
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
  # TODO filename and fastastring are only used by change via script action
  def contig_params
    params.require(:contig).permit(:mira, :marker, :marker_id, :overlap_length, :allowed_mismatch_percent, :imported,
                                   :filename, :fastastring, :comment, :assembled, :name, :consensus, :marker_id,
                                   :isolate_id, :marker_sequence_id, :term, :isolate_name, :verified, :verified_by,
                                   project_ids: [])
  end
end
