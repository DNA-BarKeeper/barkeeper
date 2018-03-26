namespace :data do

  desc 'Get information about marker sequences in database'
  task :sequence_info => :environment do
    marker_sequences = MarkerSequence.all
    sequence_count = {}
    sequence_length_avg = {}
    sequence_length_min = {}
    sequence_length_max = {}
    reads_per_contig_avg = {}
    reads_per_contig_min = {}
    reads_per_contig_max = {}

    Marker.all.each do |marker|
      sequences = marker_sequences.where(marker_id: marker.id)
      contigs = Contig.joins(:primer_reads).where(marker_id: marker.id)

      if sequences.size.positive?
        sequence_count[marker.name] = sequences.size
        sequence_length_avg[marker.name] = sequences.average('length(sequence)').to_f.round(2)
        sequence_length_min[marker.name] = sequences.where.not(:sequence => nil).order('length(sequence) asc').first.sequence.length
        sequence_length_max[marker.name] = sequences.where.not(:sequence => nil).order('length(sequence) desc').first.sequence.length
      end

      if contigs.size.positive?
        primer_read_counts = contigs.group(:id).count('primer_reads.id')

        reads_per_contig_avg[marker.name] = (primer_read_counts.values.sum/primer_read_counts.values.size.to_f).round(2)
        reads_per_contig_min[marker.name] = primer_read_counts.values.min
        reads_per_contig_max[marker.name] = primer_read_counts.values.max
      end
    end

    puts 'Number of sequences per marker:'
    p sequence_count
    puts 'Average sequence length per marker:'
    p sequence_length_avg
    puts 'Minimum sequence length per marker:'
    p sequence_length_min
    puts 'Maximum sequence length per marker:'
    p sequence_length_max
    puts 'Average reads per contig per marker:'
    p reads_per_contig_avg
    puts 'Minimum reads per contig per marker:'
    p reads_per_contig_min
    puts 'Maximum reads per contig per marker:'
    p reads_per_contig_max

    puts "Number of marker sequences: #{marker_sequences.size}"
    # puts "Number of marker sequences with associated contigs: #{marker_sequences.includes(:contigs).where.not(contigs: {id: nil}).size}"
    puts "Number of marker sequences without associated contigs: #{marker_sequences.includes(:contigs).where(contigs: {id: nil}).size}"

    puts "Number of marker sequences without associated isolate: #{marker_sequences.includes(:isolate).where(isolate: nil).size}"

    puts "Number of specimen in database: #{Individual.all.size}"
  end
end
