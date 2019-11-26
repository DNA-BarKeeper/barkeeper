# frozen_string_literal: true

namespace :data do
  desc 'Compare contig consensus sequences and resulting marker sequences. Alert if different.'
  task check_consensus_sequences: :environment do
    puts 'Checking contig consensus sequences...'

    contigs = Contig.gbol.includes(:marker_sequence, :partial_cons).where.not(marker_sequence: nil).select(:id, :name, :marker_sequence_id)
    alert = []
    no_sequence = []
    ms_blank = []

    contigs.first(200).each do |contig|
      marker_sequence = contig.marker_sequence.sequence
      if marker_sequence.blank?
        ms_blank << contig.name
      else
        partial_sequence = contig.partial_cons.first&.aligned_sequence

        if partial_sequence.blank?
          no_sequence << contig.name
        else
          # Marker sequences are created from modified aligned_sequence of first partial con after verification
          partial_sequence = partial_sequence.delete('?').delete('-')

          alert << contig.name if marker_sequence != partial_sequence
        end
      end
    end

    puts "Done. Incongruities found for #{alert.size} contigs:"
    p alert

    puts "#{no_sequence.size} contigs had no consensus sequence."

    puts "#{ms_blank.size} contigs had no marker sequence."
  end
end
