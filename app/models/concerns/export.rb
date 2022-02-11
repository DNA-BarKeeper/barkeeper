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

module Export
  extend ActiveSupport::Concern

  PDE_BEGINNING = '<?xml version="1.0" standalone="no"?>'\
                  "<!-- Generated by a BarKeeper web app #{Time.zone.now}  -->"\
                  '<phyde id="wL6obVNH1kuwviaB" version="0.994">'\
                  '<description></description>'

  PDE_CLOSURE = '</block></matrix></alignment></phyde>'

  module ClassMethods
    def pde(records, options)
      @pde_header = "<header><entries>32 \"Taxon\" STRING\n33 \"GBOL5 URL\" STRING</entries>"

      pde_matrix = +''
      @height = 0 # Number of lines (needed for pde dimensions)
      @max_width = 0 # Number of alignment columns
      @block_seqs = [] # Collect sequences for block, later fill with '?' up to max_width

      if records.first.is_a? Contig
        pde_contigs(records, options[:add_reads])
      elsif records.first.is_a? MarkerSequence
        pde_marker_sequences(records)
      end

      @pde_header += "</header>\n"

      pde_dimensions = "<alignment datatype=\"dna\" width=\"#{@max_width}\" height=\"#{@height}\" gencode=\"0\" offset=\"-1\">"

      pde_matrix_dimensions = "<block x=\"0\" y=\"0\" width=\"#{@max_width}\" height=\"#{@height}\">"

      @block_seqs.each do |seq|
        (@max_width - seq.length).times { seq += '?' }
        pde_matrix += "#{seq}\\FF\n"
      end

      PDE_BEGINNING + pde_dimensions + @pde_header + '<matrix>' + pde_matrix_dimensions + pde_matrix + PDE_CLOSURE
    end

    def fasta(records, options)
      @fasta = +''

      if records.first.is_a? Contig
        fasta_contigs(records, options[:mode])
      elsif records.first.is_a? MarkerSequence
        fasta_marker_sequences(records, options[:metadata], options[:warnings])
      end

      @fasta
    end

    def fastq(contigs, use_mira)
      @fastq = +''

      contigs.each do |contig|
        next if contig.partial_cons_count != 1
        @fastq += add_sequence_to_fastq(contig, use_mira)
      end

      @fastq
    end

    def taxonomy_file(sequences)
      taxa = +''

      sequences.includes(isolate: [individual: :taxon]).each do |marker_sequence|
        if marker_sequence.sequence
          ancestors = marker_sequence.try(:isolate).try(:individual).try(:taxon).try(:ancestors)
          taxonomy = ancestors.map(&:scientific_name).join(';')

          taxa << marker_sequence.name.delete(' ')
          taxa << "_#{marker_sequence.isolate&.individual&.taxon&.scientific_name&.gsub(' ', '_')}"
          taxa << "\t"
          taxa << "Eukaryota;#{taxonomy}\n"
        end
      end

      taxa
    end

    private

    def pde_contigs(contigs, add_reads)
      contigs.each do |contig|
        taxon = contig.try(:isolate).try(:individual).try(:taxon)&.scientific_name
        contig_name = taxon.blank? ? contig.name : [contig.name, taxon.tr(' ', '_')].join('_')

        contig.partial_cons.each do |partial_con|
          aligned_sequence = partial_con.aligned_sequence.nil? ? '' : partial_con.aligned_sequence

          partial_con.primer_reads.each { |read| add_primer_read_to_pde(read, true) } if add_reads

          add_sequence_to_pde(contig_name, taxon, routes.edit_contig_url(contig, url_options), aligned_sequence, false)
        end

        next unless add_reads

        # Add unassembled reads:
        contig.primer_reads.not_assembled.each { |read| add_primer_read_to_pde(read, false) } if contig.primer_reads.not_assembled.count > 0

        contig.primer_reads.not_used_for_assembly.each { |read| add_primer_read_to_pde(read, false) } if contig.primer_reads.not_used_for_assembly.count > 0

        contig.primer_reads.not_trimmed.each { |read| add_primer_read_to_pde(read, false) } if contig.primer_reads.not_trimmed.count > 0

        contig.primer_reads.unprocessed.each { |read| add_primer_read_to_pde(read, false) } if contig.primer_reads.unprocessed.count > 0
      end
    end

    def pde_marker_sequences(marker_sequences)
      marker_sequences.each do |marker_sequence|
        taxon = marker_sequence.try(:isolate).try(:individual).try(:taxon)&.scientific_name
        name = taxon.blank? ? marker_sequence.name : [marker_sequence.name, taxon.tr(' ', '_')].join('_')

        add_sequence_to_pde(name, taxon, routes.edit_marker_sequence_url(marker_sequence, url_options), marker_sequence.sequence, false)
      end
    end

    def fasta_contigs(contigs, mode)
      contigs.each do |contig|
        case mode
        when 'assembled'
          counter = 1
          contig.partial_cons.each do |partial_con|
            partial_con.primer_reads.each do |read|
              add_sequence_to_fasta(read.name, read.aligned_seq)
            end

            name = contig.partial_cons.count > 1 ? ">#{contig.name} - consensus #{counter}" : ">#{contig.name} - consensus"
            counter += 1

            add_sequence_to_fasta(name, partial_con.aligned_sequence)
          end
        when 'trimmed'
          used_reads = contig.primer_reads.where('used_for_con = ? AND assembled = ?', true, true).order('position')
          used_reads.each do |read|
            add_sequence_to_fasta(read.name, read.trimmed_seq)
          end
        when 'raw'
          used_reads = contig.primer_reads.where('used_for_con = ? AND assembled = ?', true, true).order('position')
          used_reads.each do |read|
            add_sequence_to_fasta(read.name, read.sequence)
          end
        else
          @fasta = "Parameter #{mode} was not recognized."
        end
      end
    end

    def fasta_marker_sequences(sequences, meta_data, warnings=false)
      sequences.each do |marker_sequence|
        name = marker_sequence.name.delete(' ')

        if meta_data
          name << "|#{marker_sequence.isolate&.display_name}" # Isolate
          name << "|#{marker_sequence.isolate&.individual&.specimen_id}" # Specimen
          name << "|#{marker_sequence.isolate&.individual&.taxon&.scientific_name&.gsub(' ', '_')}" # Taxon
          name << "|#{marker_sequence.isolate&.individual&.taxon&.ancestors.where(taxonomic_rank: "is_family").first&.scientific_name}" # Family
        else
          name << "_#{marker_sequence.isolate&.individual&.taxon&.scientific_name&.gsub(' ', '_')}" # Taxon
        end

        name << "|sativa_warning" if warnings && marker_sequence.has_unsolved_mislabels # Label sequences with SATIVA warnings

        add_sequence_to_fasta(name, marker_sequence.sequence) if marker_sequence.sequence
      end
    end

    def routes
      Rails.application.routes.url_helpers
    end

    def url_options
      ActionMailer::Base.default_url_options
    end

    def add_sequence_to_pde(name, taxon, url, sequence, is_primer_read)
      sequence ||= ''

      @pde_header += "<seq idx=\"#{@height}\">"\
                   "<e id=\"1\">#{name}</e>"

      @pde_header += "<e id=\"2\">#{name}</e>" if is_primer_read

      @pde_header += "<e id=\"32\">#{taxon}</e>" unless is_primer_read

      @pde_header += "<e id=\"33\">#{url}</e>"\
                     "</seq>\n"

      @block_seqs << sequence
      @height += 1

      @max_width = sequence.length if sequence.length > @max_width
    end

    def add_primer_read_to_pde(primer_read, assembled)
      sequence = assembled ? primer_read.aligned_seq : primer_read.sequence
      add_sequence_to_pde(primer_read.file_name_id, '', routes.edit_primer_read_url(primer_read, url_options), sequence, true)
    end

    def add_sequence_to_fasta(name, sequence)
      @fasta += ">#{name}\n"
      @fasta += "#{sequence.scan(/.{1,80}/).join("\n")}\n"
    end

    def add_sequence_to_fastq(contig, use_mira)
      partial_con = contig.partial_cons.first

      # Compute coverage
      used_nucleotides_count = 0

      partial_con.primer_reads.each do |r|
        used_nucleotides_count += (r.aligned_seq.length - r.aligned_seq.count('-'))
      end

      coverage = (used_nucleotides_count.to_f / partial_con.aligned_sequence.length)
      header += "@#{contig.name} | #{format('%.2f', coverage)}"
      raw_cons = partial_con.aligned_sequence

      consensus = +''
      qualities = +''
      count = 0

      qualities_to_use = use_mira ? partial_con.mira_consensus_qualities : partial_con.aligned_qualities

      qualities_to_use.each do |q|
        next unless q > 0
        consensus += raw_cons[count]
        qualities += (q + 33).chr
        count += 1
      end

      # Return empty string in case that sequence and qualities do not have the same length
      return '' unless consensus.length == qualities.length

      "#{header}\n#{consensus}\n+\n#{qualities}\n"
    end
  end
end
