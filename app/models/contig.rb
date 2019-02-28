# frozen_string_literal: true

# noinspection RubyStringKeysInHashInspection
class Contig < ApplicationRecord
  include Export
  include ProjectRecord

  belongs_to :marker_sequence
  belongs_to :marker
  belongs_to :isolate
  has_many :primer_reads, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :partial_cons, dependent: :destroy

  before_destroy { marker_sequence&.destroy }
  after_save { marker_sequence&.destroy unless assembled? }

  validates_presence_of :name

  scope :assembled, -> { where(assembled: true) }
  scope :not_assembled, -> { where.not(assembled: true) }

  scope :verified, -> { where(verified: true) }
  scope :need_verification, -> { assembled.where(verified: false) }
  scope :externally_edited, -> { where(imported: true) }
  scope :internally_edited, -> { where(imported: false) }
  scope :externally_verified, -> { externally_edited.verified }
  scope :internally_verified, -> { internally_edited.verified }

  scope :unsolved_warnings, -> { joins(marker_sequence: :mislabels).where(marker_sequence: { mislabels: { solved: false } }) }

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    # TODO: (how to) includes spp. etc (on top of individual)
    contigs = Contig.select('species_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    contigs_s = Contig.select('species_component').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    contigs_i = Contig.select('individual_id').includes(isolate: :individual).joins(isolate: { individual: { species: { family: { order: :higher_order_taxon } } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })

    [contigs.count, contigs_s.distinct.count, contigs.distinct.count, contigs_i.distinct.count]
  end

  def isolate_name
    isolate.try(:lab_nr)
  end

  def isolate_name=(name)
    if name == ''
      self.isolate = nil
    else
      self.isolate = Isolate.find_or_create_by(lab_nr: name) if name.present? # TODO is it used? Add project if so
    end
  end

  def marker_sequence_name
    marker_sequence.try(:name)
  end

  def marker_sequence_name=(name)
    if name == ''
      self.marker_sequence = nil
    else
      self.marker_sequence = MarkerSequence.find_or_create_by(name: name) if name.present? # TODO is it used? Add project if so
    end
  end

  def generate_name
    self.name = if marker.present? && isolate.present?
                  "#{isolate.lab_nr}_#{marker.name}"
                else
                  '<unnamed>'
                end
  end

  def mda(width, height)
    Array.new(width).map! { Array.new(height) }
  end

  def degapped_consensus
    consensus.delete('-')
  end

  def as_fasq(mira)
    use_mira = false

    use_mira = true if (mira == '1') || (mira == 1)

    # restrict to cases with partial_cons count == 1
    if (partial_cons.count > 1) || (partial_cons.count < 1)
      puts 'Must have 1 partial_cons.'
      return
    end

    pc = partial_cons.first

    # compute coverage
    used_nucleotides_count = 0

    pc.primer_reads.each do |r|
      used_nucleotides_count += (r.aligned_seq.length - r.aligned_seq.count('-'))
    end

    coverage = (used_nucleotides_count.to_f / pc.aligned_sequence.length)

    # header
    fasq_str = "@#{name} | #{format '%.2f', coverage}"

    # seq
    raw_cons = pc.aligned_sequence

    # seq_no_gaps = raw_cons.gsub(/-/, '') #-> does not work like this, quality score array may contain > 0 values where cons. has gap

    cons_seq = ''
    qual_str = ''

    ctr = 0

    qualities_to_use = if use_mira
                         pc.aligned_qualities
                       else
                         pc.mira_consensus_qualities
                       end

    qualities_to_use.each do |q|
      next unless q > 0
      cons_seq += raw_cons[ctr]
      qual_str += (q + 33).chr
      ctr += 1
    end

    # check that seq + qual have same length -> for externally verified this needs not be true
    unless cons_seq.length == qual_str.length
      puts "Error: seq (#{seq_no_gaps.length}) + qual (#{ctr}) do not have same length"
      return
    end

    "#{fasq_str}\n#{cons_seq}\n+\n#{qual_str}\n"
  end

  def post_assembly(update_ms, sequence, msg)
    if update_ms
      update(assembled: true)
      ms = MarkerSequence.find_or_create_by(name: name)
      ms.sequence = sequence
      ms.contigs << self
      ms.marker = marker
      ms.isolate = isolate
      ms.add_projects(projects.pluck(:id))
      ms.save

      self.marker_sequence = ms
    end

    if msg
      issue = Issue.create(title: msg, contig_id: id)
      issue.add_projects(projects.pluck(:id))
      issue.save
      self.assembled = false
    end

    self.save
  end

  def auto_overlap
    partial_cons.destroy_all
    primer_reads.use_for_assembly.update_all(assembled: false)

    remaining_reads = Array.new(primer_reads.use_for_assembly) # Creates local Array to mess around without affecting database
    msg = nil

    # Test how many
    if remaining_reads.size > 10
      # TODO: Arbitrary, change
      msg = 'Currently no more than 10 reads allowed for assembly.'
      post_assembly(false, '', msg)
      return
    elsif remaining_reads.size == 1
      single_read = primer_reads.use_for_assembly.first
      pc = PartialCon.create(aligned_sequence: single_read.trimmed_and_cleaned_seq, aligned_qualities: single_read.trimmed_quals, contig_id: id)
      single_read.aligned_qualities = single_read.trimmed_quals
      single_read.aligned_seq = single_read.trimmed_and_cleaned_seq
      single_read.assembled = true
      single_read.get_aligned_peak_indices
      single_read.save
      pc.primer_reads << single_read
      partial_cons << pc

      post_assembly(true, single_read.trimmed_and_cleaned_seq, msg)
      return
    elsif remaining_reads.empty?
      msg = 'Need at least 1 read for creating consensus sequence.'
      post_assembly(false, '', msg)
      return
    end

    # Test if trimmed_Seq

    starting_read = remaining_reads.delete_at(0) # Deletes the element at the specified index, returning that element, or nil if the index is out of range.

    assembled_reads = [starting_read] # successfully overlapped reads
    growing_consensus = { reads: [{ read: starting_read,
                                    aligned_seq: starting_read.trimmed_and_cleaned_seq,
                                    aligned_qualities: starting_read.trimmed_quals }],
                          consensus: starting_read.trimmed_and_cleaned_seq,
                          consensus_qualities: starting_read.trimmed_quals }

    partial_contigs = [] # contains singleton reads and successful overlaps (sub-contigs) that
    # themselves are isolated (including the single & final contig if everything could be overlapped)
    # format: partial_contigs.push({:reads => assembled_reads, :consensus => growing_consensus })

    assemble(growing_consensus, assembled_reads, partial_contigs, remaining_reads)

    # -----> ASSEMBLY <------

    current_largest_partial_contig = 0
    current_largest_partial_contig_seq = nil

    # clean previously stored partial_cons:
    partial_cons.destroy_all

    height = 0 # count needed lines for pde dimensions
    max_width = 0

    block_seqs = [] # collect sequences for block, later fill with '?' up to max_width

    partial_contigs.each do |partial_contig|
      # single partial_contig: ({:reads => assembled_reads, :consensus => growing_consensus})

      if partial_contig[:reads].size > 1 # something where 2 or more primers overlapped:

        # growing_consensus = {:reads => [{:read => starting_read, :aligned_seq => starting_read.trimmed_and_cleaned_seq}],
        # :consensus => starting_read.trimmed_and_cleaned_seq }

        if partial_contig[:reads].size > current_largest_partial_contig
          current_largest_partial_contig = partial_contig[:reads].size
          current_largest_partial_contig_seq = partial_contig[:consensus][:consensus]
        end

        growing_consensus = partial_contig[:consensus]

        pc = PartialCon.create(aligned_sequence: growing_consensus[:consensus], aligned_qualities: growing_consensus[:consensus_qualities])

        growing_consensus[:reads].each do |aligned_read|
          # Get original primer_read from db:
          pr = PrimerRead.find(aligned_read[:read].id)
          pr.update(aligned_seq: aligned_read[:aligned_seq], assembled: true, aligned_qualities: aligned_read[:aligned_qualities])

          pr.get_aligned_peak_indices # <-- uses aligned_qualities to populate aligned_peak_indices array. Needed in new variant of d3.js contig slize

          pc.primer_reads << pr
        end

        partial_cons << pc
      else # singleton
      end
    end

    update_ms = current_largest_partial_contig >= marker.expected_reads && current_largest_partial_contig_seq
    sequence = update_ms ? current_largest_partial_contig_seq.delete('-') : ''
    post_assembly(update_ms, sequence, msg)
  end

  # Recursive assembly function
  def assemble(growing_consensus, assembled_reads, partial_contigs, remaining_reads)
    # Try overlap all remaining_reads with growing_consensus
    none_overlapped = true

    remaining_reads.each do |read|
      aligned_seqs = overlap(growing_consensus, read.trimmed_and_cleaned_seq, read.trimmed_quals)

      next unless aligned_seqs # if one overlaps

      none_overlapped = false

      # only in case overlap worked copy the adjusted_aligned sequences that are returned from "overlap" over to growing_consensus:
      (0...aligned_seqs[:adjusted_prev_aligned_reads].size).each do |i|
        growing_consensus[:reads][i][:aligned_seq] = aligned_seqs[:adjusted_prev_aligned_reads][i]
        growing_consensus[:reads][i][:aligned_qualities] = aligned_seqs[:adjusted_prev_aligned_qualities][i]
      end

      growing_consensus[:reads].push(read: read,
                                     aligned_seq: aligned_seqs[:read_seq],
                                     aligned_qualities: aligned_seqs[:read_qal])

      # move it into assembled_reads
      overlapped_read = remaining_reads.delete(read)
      assembled_reads.push(overlapped_read)

      r = compute_consensus(aligned_seqs[:growing_cons_seq],
                            aligned_seqs[:growing_consensus_qualities],
                            aligned_seqs[:read_seq],
                            aligned_seqs[:read_qal])

      growing_consensus[:consensus] = r.first
      growing_consensus[:consensus_qualities] = r.last

      # break loop through remaining_reads
      break
    end

    # if none overlaps,
    if none_overlapped

      # move assembled_reads into partial_contigs_and_singleton_reads
      partial_contigs.push(reads: assembled_reads, consensus: growing_consensus)

      # move first of remaining_reads into growing_consensus & assembled_reads
      # ( just as during initializing prior to first function call)

      new_starting_read = remaining_reads.delete_at(0)

      if new_starting_read # catch case when new aligned_read could not be pruned

        growing_assembled_reads_reset = [new_starting_read]

        growing_consensus_reset = { reads: [{ read: new_starting_read,
                                              aligned_seq: new_starting_read.trimmed_and_cleaned_seq,
                                              aligned_qualities: new_starting_read.trimmed_quals }],
                                    consensus: new_starting_read.trimmed_and_cleaned_seq, consensus_qualities: new_starting_read.trimmed_quals }

        assemble(growing_consensus_reset, growing_assembled_reads_reset, partial_contigs, remaining_reads)
      end

    else

      assemble(growing_consensus, assembled_reads, partial_contigs, remaining_reads)

    end
  end

  # Perform Needleman-Wunsch-based overlapping:
  def overlap(growing_cons_hash, read, qualities)
    growing_consensus = growing_cons_hash[:consensus]
    growing_consensus_qualities = growing_cons_hash[:consensus_qualities]

    previously_aligned_reads = []
    previously_aligned_qualities = []

    growing_cons_hash[:reads].each do |curr_read|
      previously_aligned_reads.push(curr_read[:aligned_seq])
      previously_aligned_qualities.push(curr_read[:aligned_qualities])
    end

    gap = -5

    # similarity matrix
    s = { 'AA' =>  1,
          'AG' => -1,
          'AC' => -1,
          'AT' => -1,
          'AN' => -1,
          'A-' => -1,
          'GA' => -1,
          'GG' =>  1,
          'GC' => -1,
          'GT' => -1,
          'GN' => -1,
          'G-' => -1,
          'CA' => -1,
          'CG' => -1,
          'CC' =>  1,
          'CT' => -1,
          'CN' => -1,
          'C-' => -1,
          'TA' => -1,
          'TG' => -1,
          'TC' => -1,
          'TT' =>  1,
          'TN' => -1,
          'T-' => -1,
          'NA' => -1,
          'NG' => -1,
          'NC' => -1,
          'NT' => -1,
          'NN' => 1,
          'N-' => 1,
          '-A' => -1,
          '-G' => -1,
          '-C' => -1,
          '-T' => -1,
          '--' => 1 }

    rows = read.length + 1
    cols = growing_consensus.length + 1

    a = mda(rows, cols)

    # Since we would like not to penalize start gaps, this can be accounted for by initializing the first row and first column of
    # the dynamic programming table to zeros. This is to say that the part of the alignment that starts with gaps in x or gaps in y is given
    # a score of zero.

    for i in 0...rows do a[i][0] = 0 end
    for j in 0...cols do a[0][j] = 0 end

    (1...rows).each do |i|
      (1...cols).each do |j|
        choice1 = a[i - 1][j - 1] + s[(read[i - 1] + growing_consensus[j - 1]).upcase] # match
        choice2 = a[i - 1][j] + gap # insert
        choice3 = a[i][j - 1] + gap # delete
        a[i][j] = [choice1, choice2, choice3].max
      end
    end

    aligned_read_seq = '' # -> aligned_read
    aligned_read_qual = []

    aligned_cons_seq = '' # -> growing_consensus
    aligned_cons_qual = []

    adjusted_prev_aligned_reads = []
    adjusted_prev_aligned_qualities = []

    (0...previously_aligned_reads.size).each do |_|
      new_seq = ''
      adjusted_prev_aligned_reads.push(new_seq)
      adjusted_prev_aligned_qualities.push([])
    end

    # for classic Needleman-Wunsch:

    # start from lowermost rightmost cell

    # for overlap:

    # the best score is now in A(m, j) such that A(m, j) = max_k,l(A(k,n),A(m,l)) and the alignment itself can be
    # obtained by tracing back from A(m, j) to A(0, 0) as before.

    i = read.length
    j = growing_consensus.length

    bestscore = a[i][j]
    bestscore_i = i
    bestscore_j = j

    while i > 0
      if a[i][j] > bestscore
        bestscore = a[i][j]
        bestscore_i = i
        bestscore_j = j
      end
      i -= 1
    end

    i = read.length
    j = growing_consensus.length

    while j > 0
      if a[i][j] > bestscore
        bestscore = a[i][j]
        bestscore_i = i
        bestscore_j = j
      end
      j -= 1
    end

    # add extending overlapping aligned_cons_seq

    i = read.length
    j = growing_consensus.length

    # add 5' extending gaps...
    while i > bestscore_i
      aligned_read_seq = read[i - 1].chr + aligned_read_seq
      aligned_read_qual.unshift(qualities[i - 1])

      aligned_cons_seq += '-'
      aligned_cons_qual.push(-1) # -1 ~ '-'

      # mirror everything that's done to aligned_cons_seq in all previously aligned_seqs:
      for k in 0...adjusted_prev_aligned_reads.size do
        adjusted_prev_aligned_reads[k] = adjusted_prev_aligned_reads[k] + '-'
        adjusted_prev_aligned_qualities[k].push(-1)
      end

      i -= 1
    end

    while j > bestscore_j
      aligned_read_seq += '-'
      aligned_read_qual.push(-1)
      aligned_cons_seq = growing_consensus[j - 1].chr + aligned_cons_seq
      aligned_cons_qual.unshift(growing_consensus_qualities[j - 1])

      for k in 0...adjusted_prev_aligned_reads.size do
        adjusted_prev_aligned_reads[k] = previously_aligned_reads[k][j - 1].chr + adjusted_prev_aligned_reads[k]
        adjusted_prev_aligned_qualities[k].unshift(previously_aligned_qualities[k][j - 1])
      end

      j -= 1
    end

    # tracing back...

    i = bestscore_i
    j = bestscore_j

    while (i > 0) && (j > 0)
      score = a[i][j]
      score_diag = a[i - 1][j - 1]
      score_up = a[i][j - 1]
      score_left = a[i - 1][j]
      if score == score_diag + s[read[i - 1].chr + growing_consensus[j - 1].chr] # match
        aligned_read_seq = read[i - 1].chr + aligned_read_seq
        aligned_read_qual.unshift(qualities[i - 1])
        aligned_cons_seq = growing_consensus[j - 1].chr + aligned_cons_seq
        aligned_cons_qual.unshift(growing_consensus_qualities[j - 1])

        for k in 0...adjusted_prev_aligned_reads.size do
          adjusted_prev_aligned_reads[k] = previously_aligned_reads[k][j - 1].chr + adjusted_prev_aligned_reads[k]
          adjusted_prev_aligned_qualities[k].unshift(previously_aligned_qualities[k][j - 1])
        end

        i -= 1
        j -= 1
      elsif score == score_left + gap # insert
        aligned_read_seq = read[i - 1].chr + aligned_read_seq
        aligned_read_qual.unshift(qualities[i - 1])
        aligned_cons_seq = '-' + aligned_cons_seq
        aligned_cons_qual.unshift(-1)

        for k in 0...adjusted_prev_aligned_reads.size do
          adjusted_prev_aligned_reads[k] = '-' + adjusted_prev_aligned_reads[k]
          adjusted_prev_aligned_qualities[k].unshift(-1)
        end

        i -= 1
      elsif score == score_up + gap # delete
        aligned_read_seq = '-' + aligned_read_seq
        aligned_read_qual.unshift(-1)
        aligned_cons_seq = growing_consensus[j - 1].chr + aligned_cons_seq
        aligned_cons_qual.unshift(growing_consensus_qualities[j - 1])

        for k in 0...adjusted_prev_aligned_reads.size do
          adjusted_prev_aligned_reads[k] = previously_aligned_reads[k][j - 1].chr + adjusted_prev_aligned_reads[k]
          adjusted_prev_aligned_qualities[k].unshift(previously_aligned_qualities[k][j - 1])
        end

        j -= 1
      end
    end

    # add 3' extending gaps...
    while i > 0
      aligned_read_seq = read[i - 1].chr + aligned_read_seq
      aligned_read_qual.unshift(qualities[i - 1])
      aligned_cons_seq = '-' + aligned_cons_seq
      aligned_cons_qual.unshift(-1)

      # mirror everything that's done to aligned_cons_seq in all previously aligned_seqs:
      for k in 0...adjusted_prev_aligned_reads.size do
        adjusted_prev_aligned_reads[k] = '-' + adjusted_prev_aligned_reads[k]
        adjusted_prev_aligned_qualities[k].unshift(-1)
      end

      i -= 1
    end

    while j > 0
      aligned_read_seq = '-' + aligned_read_seq
      aligned_read_qual.unshift(-1)
      aligned_cons_seq = growing_consensus[j - 1].chr + aligned_cons_seq
      aligned_cons_qual.unshift(growing_consensus_qualities[j - 1])

      # mirror everything that's done to aligned_cons_seq in all previously aligned_seqs:
      for k in 0...adjusted_prev_aligned_reads.size do
        adjusted_prev_aligned_reads[k] = previously_aligned_reads[k][j - 1].chr + adjusted_prev_aligned_reads[k]
        adjusted_prev_aligned_qualities[k].unshift(previously_aligned_qualities[k][j - 1])
      end

      j -= 1
    end

    msg = ''
    msg_type = 1

    aligned_seqs = { growing_cons_seq: aligned_cons_seq,
                     growing_consensus_qualities: aligned_cons_qual,

                     read_seq: aligned_read_seq,
                     read_qal: aligned_read_qual,

                     adjusted_prev_aligned_reads: adjusted_prev_aligned_reads,
                     adjusted_prev_aligned_qualities: adjusted_prev_aligned_qualities,

                     message: msg,
                     message_type: msg_type }

    # puts "growing_cons_seq:"
    # puts aligned_seqs[:growing_cons_seq]
    # puts "read_seq:"
    # puts aligned_seqs[:read_seq]

    # check if overlap worked or crappy alignment resulted:

    diffs = 0
    valids = 0

    conflicting_positions = []

    (0...aligned_seqs[:growing_cons_seq].length).each do |m|
      if (aligned_seqs[:growing_cons_seq][m] == '-') || (aligned_seqs[:read_seq][m] == '-')
        next
      else
        valids += 1
      end

      if aligned_seqs[:growing_cons_seq][m] != aligned_seqs[:read_seq][m]
        diffs += 1
        conflicting_positions << m
      end
    end

    perc = (diffs.to_f / valids)

    if perc <= allowed_mismatch_percent / 100.0

      # wenn zu wenig overlap:
      if valids < overlap_length
        # return nil
        nil
      else
        # return alignment:
        aligned_seqs[:message] = perc
        aligned_seqs
      end

    else
      # return nil
      nil

    end
  end

  def not_assembled
    primer_reads.not_assembled.as_json
  end

  def compute_consensus(seq1, qual1, seq2, qual2)
    consensus_seq = ''
    consensus_qal = []

    for i in 0...seq1.length

      if (qual1[i] == -1) || (qual2[i] == -1)

        if (qual1[i] == -1) && (qual2[i] == -1)
          consensus_qal.push(-1)
          consensus_seq += '-'
        else
          if qual1[i] == -1

            # if further gap adjacent, it's most likely end of trimmed_seq --> qual2/seq2 win
            trimmed_end = false
            if i > 0
              trimmed_end = true if (qual1[i - 1] == -1) || (qual1[i + 1] == -1)
            else
              trimmed_end = true if qual1[i + 1] == -1
            end

            if trimmed_end

              consensus_seq += seq2[i]
              consensus_qal.push(qual2[i])

            else

              # get surrounding base qualities

              neighboring_qual1 = if i > 0
                                    qual1[i - 1]
                                  else
                                    qual1[i + 1]
                                  end

              if neighboring_qual1 > qual2[i]
                consensus_seq += '-'
                consensus_qal.push(neighboring_qual1)
              else
                consensus_seq += seq2[i]
                consensus_qal.push(qual2[i])
              end
            end

          elsif qual2[i] == -1

            # if further gap adjacent, it's most likely end of trimmed_seq --> qual1/seq1 win
            trimmed_end = false
            if i > 0
              trimmed_end = true if (qual2[i - 1] == -1) || (qual2[i + 1] == -1)
            else
              trimmed_end = true if qual2[i + 1] == -1
            end

            if trimmed_end

              consensus_seq += seq1[i]
              consensus_qal.push(qual1[i])

            else

              # get surrounding base qualities
              neighboring_qual2 = if i > 0
                                    qual2[i - 1]
                                  else
                                    qual2[i + 1]
                                  end

              if neighboring_qual2 > qual1[i]
                consensus_seq += '-'
                consensus_qal.push(neighboring_qual2)
              else
                consensus_seq += seq1[i]
                consensus_qal.push(qual1[i])
              end

            end
          end

        end

      else

        if qual1[i] > qual2[i]
          consensus_qal.push(qual1[i])
          consensus_seq += seq1[i]
        else
          consensus_qal.push(qual2[i])
          consensus_seq += seq2[i]
        end

      end

    end

    [consensus_seq, consensus_qal]
  end
end
