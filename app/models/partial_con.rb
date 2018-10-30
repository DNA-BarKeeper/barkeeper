# frozen_string_literal: true

class PartialCon < ApplicationRecord
  belongs_to :contig, counter_cache: true
  has_many :primer_reads

  def mira_consensus_qualities
    group_probs_all_pos = []

    # for each position:
    (0...aligned_sequence.length).each do |i|
      next if aligned_qualities[i] < 0 # cases with gap in consensus, -1 or -10
      # get group probabilities for consensus character:
      group_prob = 0
      ctr = 0
      primer_reads.each do |r|
        break if ctr > 1

        if r.aligned_seq[i] == aligned_sequence[i]
          group_prob += r.aligned_qualities[i]
        end

        ctr += 1
      end

      group_probs_all_pos << if group_prob > 93
                               93
                             else
                               group_prob
                             end
    end

    group_probs_all_pos
  end

  def test_name
    puts id
  end

  def as_json(_options = {})
    super(include: [:primer_reads])
  end

  def to_json_for_page(page, width_in_bases)
    alignment_length = aligned_qualities.blank? ? aligned_sequence.length : aligned_qualities.length # Most externally edited contigs do not have the aligned qualities array
    page = 0 if page.to_i.negative?
    start_pos = page.to_i * width_in_bases.to_i

    # Test if outside range of existing sites; if so, use last page:
    if start_pos > alignment_length
      page = (alignment_length / width_in_bases.to_i)
      start_pos = page.to_i * width_in_bases.to_i
    end

    end_pos = start_pos + (width_in_bases.to_i - 1)
    end_pos = alignment_length - 1 if end_pos > alignment_length

    {
      page: page.as_json,
      aligned_sequence: aligned_sequence[start_pos..end_pos].as_json,
      # :aligned_qualities => self.aligned_qualities[start_pos..end_pos].as_json,
      start_pos: start_pos.as_json,
      end_pos: end_pos.as_json,
      primer_reads: primer_reads.map { |pr| pr.slice_to_json(start_pos, end_pos) }
    }
  end

  def to_json_for_position(position_string, width_in_bases)
    alignment_length = aligned_qualities.blank? ? aligned_sequence.length : aligned_qualities.length # Most externally edited contigs do not have the aligned qualities array

    start_pos = position_string.to_i
    start_pos = 0 if start_pos < 0

    end_pos = start_pos + (width_in_bases.to_i - 1)
    end_pos = alignment_length - 1 if end_pos > alignment_length

    # Calculate full page number
    page = (start_pos / alignment_length).to_i

    {
      page: page.as_json,
      aligned_sequence: aligned_sequence[start_pos..end_pos].as_json,
      # :aligned_qualities => self.aligned_qualities[start_pos..end_pos].as_json,
      start_pos: start_pos.as_json,
      end_pos: end_pos.as_json,
      primer_reads: primer_reads.map { |pr| pr.slice_to_json(start_pos, end_pos) }
    }
  end
end
