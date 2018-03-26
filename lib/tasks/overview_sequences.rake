namespace :data do

  desc 'Get information about marker sequences in database'
  task :sequence_info => :environment do
    marker_sequences = MarkerSequence.all
    sequence_count = {}
    sequence_length = {}
    sequence_min = {}
    sequence_max = {}
    reads_per_contig = {}

    Marker.all.each do |marker|
      sequences = marker_sequences.where(marker_id: marker.id)
      if sequences.size > 0
        sequence_count[marker.name] = sequences.size
        sequence_length[marker.name] = sequences.average('length(sequence)').to_f.round(2)
        sequence_min[marker.name] = sequences.where.not(:sequence => nil).order('length(sequence) asc').first.sequence.length
        sequence_max[marker.name] = sequences.where.not(:sequence => nil).order('length(sequence) desc').first.sequence.length
        reads_per_contig[marker.name] = Contig.includes(:primer_reads).average(:primer_reads.size).to_f.round(2) #TODO does not work!
      end
    end

    p sequence_count
    p sequence_length
    p sequence_min
    p sequence_max
    p reads_per_contig

    puts "Number of marker sequences: #{marker_sequences.size}"
    puts "Number of marker sequences with associated contigs: #{marker_sequences.includes(:contigs).where.not(contigs: {id: nil}).size}"
    puts "Number of marker sequences without associated contigs: #{marker_sequences.includes(:contigs).where(contigs: {id: nil}).size}"

    puts "Number of marker sequences without associated isolate: #{marker_sequences.includes(:isolate).where(isolate: nil).size}"

    puts "Number of specimen in database: #{Individual.all.size}"
  end
end
