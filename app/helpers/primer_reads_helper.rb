# frozen_string_literal: true

module PrimerReadsHelper
  def render_primer_read_list(all_reads)
    all_reads.map do |primer_read|
      render primer_read
    end.join.html_safe
  end

  def seq_for_display(read)
    (read.sequence[0..30]...read.sequence[-30..-1]).to_s if read.sequence.present?
  end

  def trimmed_seq_for_display(read)
    (read.sequence[read.trimmedReadStart..read.trimmedReadStart + 30]...read.sequence[read.trimmedReadEnd - 30..read.trimmedReadEnd]).to_s if read.sequence.present?
  end

  def name_for_display(read)
    if read.name.length > 25
      (read.name[0..11]...read.name[-11..-5]).to_s
    else
      read.name[0..-5].to_s
    end
  end
end
