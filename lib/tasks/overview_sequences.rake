namespace :data do

  desc 'Get information about verified marker sequences (with associated species) and contigs in database'
  task :sequence_info_verified => [:environment, :general_info] do
    marker_sequences = MarkerSequence.has_species.verified
    contigs = Contig.verified.joins(:primer_reads)

    get_information(marker_sequences, contigs)
  end

  desc 'Get information about all marker sequences and contigs in database'
  task :sequence_info_all => [:environment, :general_info] do
    marker_sequences = MarkerSequence.all
    contigs = Contig.joins(:primer_reads)

    get_information(marker_sequences, contigs)
  end

  desc 'Get general information about marker sequences and contigs in database'
  task :general_info => :environment do
    puts "Number of marker sequences: #{MarkerSequence.all.size}"
    puts "Number of verified marker sequences in database: #{MarkerSequence.verified.size}"
    puts "Number of verified marker sequences with associated species in database: #{MarkerSequence.has_species.verified.length}"
    puts "Number of marker sequences without associated contigs: #{MarkerSequence.includes(:contigs).where(contigs: { id: nil }).size}"
    puts "Number of marker sequences without associated isolate: #{MarkerSequence.includes(:isolate).where( isolate: nil ).size}"
    puts ''

    puts "Number of contigs in database: #{Contig.all.size}"
    puts "Number of verified contigs in database: #{Contig.verified.size}"
    puts ''

    puts "Number of specimen in database: #{Individual.all.size}"
    puts ''
  end

  task :duplicate_sequences => :environment do
    gbol_sequences = MarkerSequence.where('marker_sequences.name ilike ?', 'gbol%')
    ms_with_contig = gbol_sequences.joins(:contigs).distinct

    duplicate_names = gbol_sequences.group(:name).having('count(name) > 1').count.keys
    duplicate_ms = gbol_sequences.where(marker_sequences: { name: duplicate_names })
    duplicate_ms_contig = ms_with_contig.where(marker_sequences: { name: duplicate_names })

    puts "Number of all marker sequences in GBOL5: #{gbol_sequences.size}"
    puts "Number of all marker sequences in GBOL5 with a contig: #{ms_with_contig.size}"
    puts "Number of duplicate sequences: #{duplicate_ms.size}"
    puts "Number of duplicate sequences with a contig: #{duplicate_ms_contig.size}"
  end

  desc 'Get the number of species with more than 1, 2, 3, 4 or 5 sequences per marker'
  task :sequences_per_species => :environment do
    species = Species.joins(individuals: [isolates: :marker_sequences]).distinct
    columns = %w(gt_one gt_two gt_three gt_four gt_five)
    its = {}
    rpl16 = {}
    trnk_matk = {}
    trnlf = {}

    columns.each_with_index do |column, i|
      trnlf[column.to_sym] = species_count_with_ms_count(species, 4, i + 1)
      its[column.to_sym] = species_count_with_ms_count(species, 5, i + 1)
      rpl16[column.to_sym] = species_count_with_ms_count(species, 6, i + 1)
      trnk_matk[column.to_sym] = species_count_with_ms_count(species, 7, i + 1)
    end

    puts 'Number of species with the given amount of marker sequences:'
    p "trnLF: #{trnlf}"
    p "ITS: #{its}"
    p "rpl16: #{rpl16}"
    p "trnK-matK: #{trnk_matk}"
  end

  def species_count_with_ms_count(species, marker_id, ms_count)
    species.where(individuals: { isolates: { marker_sequences: { marker: marker_id } } })
           .group(:id)
           .having('count(marker_sequences) > ?', ms_count).length
  end

  def get_information(marker_sequences, contigs)
    sequence_count = {}
    sequence_length_avg = {}
    sequence_length_min = {}
    sequence_length_max = {}
    reads_per_contig_avg = {}
    reads_per_contig_min = {}
    reads_per_contig_max = {}

    Marker.gbol_marker.each do |marker|
      sequences = marker_sequences.where(marker_id: marker.id)
      contigs_marker = contigs.where(marker_id: marker.id)

      if sequences.size.positive?
        sequence_count[marker.name] = sequences.size
        sequence_length_avg[marker.name] = sequences.average('length(sequence)').to_f.round(2)
        sequence_length_min[marker.name] = sequences.where.not(:sequence => nil).order('length(sequence) asc').first.sequence.length
        sequence_length_max[marker.name] = sequences.where.not(:sequence => nil).order('length(sequence) desc').first.sequence.length
      end

      if contigs_marker.size.positive?
        primer_read_counts = contigs_marker.group(:id).count('primer_reads.id') #  TODO: only count assembled reads

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
  end
end
