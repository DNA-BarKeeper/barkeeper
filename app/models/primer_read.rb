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

class PrimerRead < ApplicationRecord
  include PgSearch::Model
  include ProjectRecord

  belongs_to :contig
  belongs_to :partial_con
  belongs_to :primer
  has_many :issues, dependent: :destroy

  has_one_attached :chromatogram
  validates :chromatogram, attached: true, content_type: 'application/octet-stream'

  before_create :default_name

  multisearchable against: [:comment, :name]
  pg_search_scope :search_partial_name,
                  against: :name,
                  using: {
                    trigram: {
                      threshold: 0.2
                    }
                  }

  scope :assembled, -> { use_for_assembly.where(assembled: true) }
  scope :not_assembled, -> { use_for_assembly.where(assembled: false) }

  scope :use_for_assembly, -> { trimmed.where(used_for_con: true) }
  scope :not_used_for_assembly, -> { trimmed.where(used_for_con: false) }

  scope :trimmed, -> { where.not(trimmedReadStart: nil) }
  scope :not_trimmed, -> { where(trimmedReadStart: nil) }

  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }
  scope :contig_not_verified, -> { joins(:contig).where(contigs: { verified: false, verified_by: nil }) }

  scope :unsolved_issues, -> { includes(:issues).where(issues: { solved: false }) }

  def file_name_id
    name.gsub('.', "_#{id}.")
  end

  def slice_to_json(start_pos, end_pos)
    # get trace position corresponding to first / last aligned_peaks index that exists and is not -1:

    start_pos_trace = start_pos
    end_pos_trace = end_pos

    xstart = aligned_peak_indices[start_pos_trace]

    while xstart == -1
      start_pos_trace += 1
      xstart = aligned_peak_indices[start_pos_trace]
    end

    # does aligned_peaks index exist?
    if aligned_peak_indices[end_pos_trace]
      xend = aligned_peak_indices[end_pos_trace]
      # else use last:
    else
      end_pos_trace = aligned_peak_indices.count - 1
      xend = aligned_peak_indices[end_pos_trace]
    end

    # find first that isnt -1:
    while (xend == -1) && (end_pos_trace > 0)
      end_pos_trace -= 1
      xend = aligned_peak_indices[end_pos_trace]
    end

    # create hash with x-pos as key, ya, yc, … as value
    traces = {}

    if xstart && xend # account for situations where nothing from this read is seen in respective contig slice/page:

      xstart -= 10
      xend += 10

      (xstart..xend).each do |x|
        traces[x] = {
          ay: atrace[x],
          cy: ctrace[x],
          gy: gtrace[x],
          ty: ttrace[x]
        }
      end
    end

    # get position in original, non-trimmed, non-aligned primer read:

    # return json

    {
      id: id.as_json,
      name: name.as_json,
      aligned_seq: aligned_seq[start_pos..end_pos].as_json,
      aligned_qualities: aligned_qualities[start_pos..end_pos].as_json,
      traces: traces.as_json,
      aligned_peak_indices: aligned_peak_indices[start_pos..end_pos].as_json,
      trimmedReadStart: trimmedReadStart.as_json,
      trimmedReadEnd: trimmedReadEnd.as_json,
      original_positions: original_positions[start_pos..end_pos].as_json
    }
  end

  def original_positions
    original_positions = []

    i = trimmedReadStart

    aligned_qualities.each do |aq|
      if aq == -1
        original_positions << -1
      else
        original_positions << i
        i += 1
      end
    end

    original_positions
  end

  def contig_name
    contig.try(:name)
  end

  def contig_name=(name)
    if name == ''
      self.contig = nil
    else
      self.contig = Contig.find_or_create_by(name: name) if name.present? # TODO is it used? Add project if so
    end
  end

  def default_name
    self.name ||= chromatogram.filename.to_s
  end

  def auto_assign
    output_message = nil
    issue_title = ''
    create_issue = false

    # Try to find matching primer
    regex_read_name = /^([A-Za-z0-9]+)(.*)_([A-Za-z0-9-]+)\.(scf|ab1)$/ # Match group 1: Isolation number, 2: stuff, 3: primer name, 4: file extension
    name_components = self.name.match(regex_read_name)

    if name_components
      primer_name = name_components[3]
      name_variants_t7 = %w[T7promoter T7 T7-1] # T7 is always forward
      name_variants_m13 = %w[M13R-pUC M13-RP M13-RP-1] # M13R-pU

      # Logic if T7promoter or M13R-pUC.scf, otherwise leave name as it is
      if name_variants_t7.include? primer_name
        rgx = /^_([A-Za-z0-9]+)_([A-Za-z0-9]+)$/
        matches = name_components[2].match(rgx) # --> uv2
        primer_name = matches[1]

        primer = Primer.where('primers.name ILIKE ?', primer_name.to_s).first
        primer ||= Primer.where('primers.alt_name ILIKE ?', primer_name.to_s).first

        if primer
          primer_name = matches[2] if primer.reverse
        else
          issue_title = 'No primer assigned'
          output_message = "Cannot find primer with name #{primer_name}."
          create_issue = true
        end
      elsif name_variants_m13.include? primer_name
        rgx = /^_([A-Za-z0-9]+)_([A-Za-z0-9]+)$/
        matches = name_components[2].match(rgx) # --> 4
        primer_name = matches[2] # --> uv4

        primer = Primer.where('primers.name ILIKE ?', primer_name.to_s).first
        primer ||= Primer.where('primers.alt_name ILIKE ?', primer_name.to_s).first

        if primer
          primer_name = matches[1] unless primer.reverse
        else
          issue_title = 'No primer assigned'
          output_message = "Cannot find primer with name #{primer_name}."
          create_issue = true
        end
      end

      # Find & assign primer

      primer = Primer.where('primers.name ILIKE ?', primer_name.to_s).first
      primer ||= Primer.where('primers.alt_name ILIKE ?', primer_name.to_s).first

      if primer
        update(primer_id: primer.id, reverse: primer.reverse)

        # find marker that primer belongs to
        marker = primer.marker

        if marker
          # Try to find matching isolate
          isolate_component = name_components[1] # Isolation number

          # BGBM cases:
          regex_db_number = /^.*(DB)[\s_]?([0-9]+)(.*)_([A-Za-z0-9-]+)\.(scf|ab1)$/ # match group 1+2: DNABank number, 3: stuff, 4: primer name, 5: file extension
          db_number_name_components = self.name.match(regex_db_number)

          if db_number_name_components
            isolate_component = "#{db_number_name_components[1]} #{db_number_name_components[2]}" # DNABank number
          end

          isolate = Isolate.where('isolates.lab_isolation_nr ILIKE ?', isolate_component.to_s).first
          isolate ||= Isolate.where('isolates.dna_bank_id ILIKE ?', isolate_component.to_s).first
          isolate ||= Isolate.create(lab_isolation_nr: isolate_component)

          isolate.update(dna_bank_id: isolate_component) if db_number_name_components
          isolate.add_projects(projects.pluck(:id))

          update(isolate_id: isolate.id)

          # Figure out which contig to assign to
          matching_contig = Contig.where('contigs.marker_id = ? AND contigs.isolate_id = ?', marker.id, isolate.id).first

          if matching_contig
            self.contig = matching_contig
            save
            output_message = "Assigned to contig #{matching_contig.name}."
          else
            # Create new contig, auto assign to primer, copy, auto-name
            contig = Contig.new(marker_id: marker.id, isolate_id: isolate.id, assembled: false)
            contig.add_projects(projects.pluck(:id))
            contig.generate_name
            contig.save

            self.contig = contig
            save

            output_message = "Created contig #{contig.name} and assigned primer read to it."
          end
        else
          issue_title = 'No marker assigned'
          output_message = "No marker assigned to primer #{primer.name}."
          create_issue = true
        end
      else
        issue_title = 'No primer assigned'
        output_message = "Cannot find primer with name #{primer_name}."
        create_issue = true
      end
    else
      issue_title = 'File name not properly formatted'
      output_message = "No isolate ID or primer name could be identified from this file name."
      create_issue = true
    end

    if create_issue
      Issue.create(title: issue_title, description: output_message, primer_read_id: id) unless issues.find_by(title: output_message).present?
    else # Everything worked
      self.contig.update(assembled: false, assembly_tried: false)
    end

    { msg: output_message, create_issue: create_issue }
  end

  def get_position_in_marker(p)
    # get position in marker

    pp = nil

    if trimmed_seq
      pp = if reverse
             p.position - trimmed_seq.length
           else
             p.position
           end
    end

    pp
  end

  def auto_trim(write_to_db)
    create_issue = false
    issue_title = ''

    begin
      chromatogram_filename = chromatogram.filename.to_s

      # Get local copy from s3
      dest = Tempfile.new(chromatogram_filename)
      dest.binmode
      dest.write(chromatogram.blob.download)

      p = /\.ab1$/

      chromatogram_ff1 = if chromatogram_filename.match(p)
                           Bio::Abif.open(dest.path)
                         else
                           Bio::Scf.open(dest.path)
                         end

      chromatogram1 = chromatogram_ff1.next_entry

      chromatogram1.complement! if reverse

      sequence = chromatogram1.sequence.upcase

      # copy chromatogram over into db
      if self.sequence.nil? || write_to_db
        update(sequence: sequence)
        update(base_count: sequence.length)
      end
      update(qualities: chromatogram1.qualities) if qualities.nil? || write_to_db
      if atrace.nil? || write_to_db
        update(atrace: chromatogram1.atrace)
        update(ctrace: chromatogram1.ctrace)
        update(gtrace: chromatogram1.gtrace)
        update(ttrace: chromatogram1.ttrace)
        update(peak_indices: chromatogram1.peak_indices)
      end

      se = []

      se = trim_seq(chromatogram1.qualities, min_quality_score, window_size, count_in_window)

      # se = self.trim_seq_inverse(chromatogram1.qualities)

      if se
        if se[0] >= se[1] # trimming has not found any stretch of bases > min_score
          issue_title = 'Very low read quality'
          msg = 'Quality too low - no stretch of readable bases found.'
          create_issue = true
          update(used_for_con: false)
        elsif se[2] > 0.6
          issue_title = 'Low read quality'
          msg = "Quality too low - #{(se[2] * 100).round}% low-quality base calls in trimmed sequence."
          create_issue = true

          update(used_for_con: false)
        else

          # everything works:

          update(trimmedReadStart: se[0] + 1, trimmedReadEnd: se[1] + 1, used_for_con: true)
          #:position => self.get_position_in_marker(self.primer)
          msg = 'Sequence trimmed.'
        end
      else
        issue_title = 'Very low read quality'
        msg = 'Quality too low - no stretch of readable bases found.'
        create_issue = true
        update(used_for_con: false)
      end
    rescue StandardError
      issue_title = 'Trimming not possible'
      msg = 'Sequence could not be trimmed - no scf/ab1 file or no quality scores?'
      create_issue = true
      update(used_for_con: false)
    end

    if create_issue
      Issue.create(title: issue_title, description: msg, primer_read_id: id) unless issues.find_by(title: msg).present?
      update(used_for_con: false)
    end

    { msg: msg, create_issue: create_issue }
  end

  def trimmed_seq
    if trimmedReadStart.nil? || trimmedReadEnd.nil?
      nil
    else
      if trimmedReadEnd > trimmedReadStart
        sequence[(trimmedReadStart - 1)..(trimmedReadEnd - 1)] if sequence.present?
        # cleaned_sequence = raw_sequence.gsub('-', '') # in case basecalls in pherogram have already '-' - as in some crappy seq. I got from BN
      end
    end
  end

  def trimmed_quals
    if trimmedReadStart.nil? || trimmedReadEnd.nil?
      nil
    else
      if trimmedReadEnd > trimmedReadStart
        qualities[(trimmedReadStart - 1)..(trimmedReadEnd - 1)] if qualities.present?
      end
    end
  end

  def trimmed_and_cleaned_seq
    trimmed_seq.upcase.gsub /[^ACTGN-]+/, 'N'
  end

  def get_aligned_peak_indices
    if trimmedReadStart
      aligned_peak_indices = []
      pi = trimmedReadStart - 2

      if aligned_qualities
        aligned_qualities.each do |aq|
          if aq == -1
            aligned_peak_indices << -1
          else
            aligned_peak_indices << peak_indices[pi]
            pi += 1
          end
        end

        update_columns(aligned_peak_indices: aligned_peak_indices)
      end
    end
  end

  def trim_seq(qualities, min_quality_score, t, c)
    trimmed_read_start = 0
    trimmed_read_end = qualities.length

    # --- find readstart:

    for i in 0..qualities.length - t
      # extract window of size t

      count = 0

      for k in i...i + t
        count += 1 if qualities[k] >= min_quality_score
      end

      if count >= c
        trimmed_read_start = i
        break
      end

    end

    # fine-tune:  if bad bases are at beginning of last window, cut further until current base's score >= min_qual:

    ctr = trimmed_read_start

    for a in ctr..ctr + t
      if qualities[a] >= min_quality_score
        trimmed_read_start = a
        break
      end
    end

    # --- find readend:

    i = qualities.length
    while i > 0
      # extract window of size t

      # k=i
      count = 0

      for k in i - t...i
        count += 1 if qualities[k] >= min_quality_score
      end

      if count >= c
        trimmed_read_end = i
        break
      end

      i -= 1

    end

    # fine-tune:  if bad bases are at beginning of last window, go back until current base's score >= min_qual:

    while i > trimmed_read_end - t
      break if qualities[i] >= min_quality_score
      i -= 1
    end
    trimmed_read_end = i

    # check if xy% < min_score:
    ctr_bad = 0
    ctr_total = 0
    for j in trimmed_read_start...trimmed_read_end
      ctr_bad += 1 if qualities[j] < min_quality_score
      ctr_total += 1
    end

    [trimmed_read_start, trimmed_read_end, ctr_bad.to_f / ctr_total.to_f]
  end
end
