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

class PartialCon < ApplicationRecord
  belongs_to :contig, counter_cache: true
  has_many :primer_reads, dependent: :nullify

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

        group_prob += r.aligned_qualities[i] if r.aligned_seq[i] == aligned_sequence[i]

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

    start_pos = position_string.to_i - 1 # Enumeration starts with one in GUI
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
