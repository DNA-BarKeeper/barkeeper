namespace :data do

  desc 'Get information about verified marker sequences (with associated species) and contigs in database'
  task :sequence_info_verified => [:environment, :general_info] do
    marker_sequences = MarkerSequence.gbol.has_species.verified
    contigs = Contig.gbol.verified.joins(:primer_reads)

    get_information(marker_sequences, contigs)
  end

  desc 'Get information about all gbol5 marker sequences and contigs in database'
  task :sequence_info_gbol => [:environment, :general_info] do
    marker_sequences = MarkerSequence.gbol
    contigs = Contig.joins(:primer_reads).gbol

    get_information(marker_sequences, contigs)
  end

  desc 'Get general information about gbol5 marker sequences and contigs in database'
  task :general_info => :environment do
    marker_sequences = MarkerSequence.gbol
    puts "Number of marker sequences: #{marker_sequences.size}"
    puts "Number of verified marker sequences in database: #{marker_sequences.verified.size}"
    puts "Number of verified marker sequences with associated species in database: #{marker_sequences.has_species.verified.length}"
    puts "Number of marker sequences without associated contigs: #{marker_sequences.includes(:contigs).where(contigs: { id: nil }).size}"
    puts "Number of marker sequences without associated isolate: #{marker_sequences.includes(:isolate).where( isolate: nil ).size}"
    puts ''

    contigs = Contig.gbol
    puts "Number of contigs in database: #{contigs.size}"
    puts "Number of verified contigs in database: #{contigs.verified.size}"
    puts ''

    puts "Number of specimen in database: #{Individual.gbol.size}"
    puts ''
  end

  task :duplicate_sequences => :environment do
    gbol_sequences = MarkerSequence.gbol
    ms_with_contig = gbol_sequences.joins(:contigs).distinct

    duplicate_names = Hash[gbol_sequences.group('marker_sequences.name').count.select { |k, v| v >= 2 }].keys
    # duplicate_names = gbol_sequences.group('marker_sequences.name').having('count(marker_sequences.name) >= 2').count.keys
    duplicate_ms = gbol_sequences.where(marker_sequences: { name: duplicate_names })
    duplicate_ms_contig = ms_with_contig.where(marker_sequences: { name: duplicate_names })

    puts "Number of all marker sequences in GBOL5: #{gbol_sequences.size}"
    puts "Number of all marker sequences in GBOL5 with a contig: #{ms_with_contig.size}"
    puts "Number of duplicate sequences: #{duplicate_ms.size}"
    puts "Number of duplicate sequences with a contig: #{duplicate_ms_contig.size}"
  end

  desc 'Get the number of species with more than 1, 2, 3, 4 or 5 sequences per marker'
  task :sequences_per_species => :environment do
    # TODO: Exclude cases where one individual has multiple isolates or one isolate has multiple sequences per marker
    species = Species.joins(individuals: [isolates: :marker_sequences]).distinct
    columns = %w(min_one gt_one gt_two gt_three gt_four gt_five)
    its = {}
    rpl16 = {}
    trnk_matk = {}
    trnlf = {}

    columns.each_with_index do |column, i|
      trnlf[column.to_sym] = species_count_with_ms_count(species, 4, i)
      its[column.to_sym] = species_count_with_ms_count(species, 5, i)
      rpl16[column.to_sym] = species_count_with_ms_count(species, 6, i)
      trnk_matk[column.to_sym] = species_count_with_ms_count(species, 7, i)
    end

    puts 'Number of species with the given amount of marker sequences:'
    p "trnLF: #{trnlf}"
    p "ITS: #{its}"
    p "rpl16: #{rpl16}"
    p "trnK-matK: #{trnk_matk}"

    # Number of individuals with more than one isolate:
    # Individual.joins(:isolates).group(:id).having('count(isolates) > ?', 1).length

    # Number of isolates per marker with more than one sequence:
    # Isolate.joins(:marker_sequences).where(marker_sequences: { marker: 5 }).group(:id).having('count(marker_sequences) > ?', 1).length
  end

  desc 'Get the number of species with only a single sequence per marker'
  task :singletons_per_marker => :environment do
    species = Species.joins(individuals: [isolates: :marker_sequences]).distinct
    species_cnt = species.size

    trnlf = species_count_with_exact_ms_count(species, 4, 1)
    its = species_count_with_exact_ms_count(species, 5, 1)
    rpl16 = species_count_with_exact_ms_count(species, 6, 1)
    trnk_matk = species_count_with_exact_ms_count(species, 7, 1)

    puts "Fraction of species with only a single barcode sequence (total of #{species_cnt} species):"
    p "trnLF: #{((trnlf.to_f / species_cnt) * 100).round(2)}%"
    p "ITS: #{((its.to_f / species_cnt) * 100).round(2)}%"
    p "rpl16: #{((rpl16.to_f / species_cnt) * 100).round(2)}%"
    p "trnK-matK: #{((trnk_matk.to_f / species_cnt) * 100).round(2)}%"
  end

  desc 'Get the average number of specimen per species'
  task :specimen_per_species => :environment do
    species_cnt = Species.all.size
    specimen_cnt = Individual.all.size

    species = Species.joins(:individuals).distinct # Species with at least one specimen

    puts "Number of species in DB: #{species_cnt}"
    puts "Number of species in DB with at least one specimen: #{species.size}"
    puts "Number of specimen in DB: #{specimen_cnt}"

    average = specimen_cnt / species_cnt.to_f

    puts "Average number of specimen per species: #{average}"

    cnt = species.group(:id).count(:individuals)
    max = cnt.max_by { |_, v| v }

    puts "Highest number of specimen per species in DB: #{max[1]}(#{Species.find(max[0]).composed_name})"

    singleton_cnt = cnt.values.count(1)

    puts "Number of species with less than two specimen: #{(species_cnt - cnt.size) + singleton_cnt}"

    # Number of marker sequences per species
    # MarkerSequence.joins(isolate: [individual: :species]).distinct.order('species.species_component').group('species.species_component').count
  end

  task :get_high_quality_sequences => :environment do
    sequences = MarkerSequence.gbol # Only GBOL5 sequences
    # sequences = MarkerSequence.gbol.joins(isolate: {individual: {species: {family: :order}}}).where("orders.name ilike ?", "%Caryophyllales%")
    puts "Number of GBOL5 sequences: #{sequences.size}"

    sequences = sequences.has_species # Only sequences with assigned species
    puts "Number of sequences with assigned species: #{sequences.size}"

    duplicate_names = sequences.group('marker_sequences.name').having('count(marker_sequences.name) > 2').count.keys
    sequences = sequences.where.not(marker_sequences: { name: duplicate_names }) # Exclude all duplicate sequences until it is solved which ones are valid
    puts "Number of sequences without duplicates: #{sequences.size}"
    puts "Duplicate sequences: #{duplicate_names.inspect}"

    puts ''

    sequences_per_marker = {}
    Marker.gbol.each do |marker|
      sequences_per_marker[marker.name.to_sym] = sequences.where(marker_id: marker.id)
      puts "Number of sequences for #{marker.name}: #{sequences_per_marker[marker.name.to_sym].size}"

      average_length = sequences_per_marker[marker.name.to_sym].average('length(sequence)').to_f.round(2)
      puts "Average length of these sequences: #{average_length}"

      threshold = (average_length * 0.70).to_f.round # Sequence length should be at least 70% of average length
      sequences_per_marker[marker.name.to_sym] = sequences_per_marker[marker.name.to_sym].where('length(sequence) > ?', threshold)
      puts "Number of sequences above length threshold of #{threshold}: #{sequences_per_marker[marker.name.to_sym].size}"

      puts ''
    end

    # Check sequences for stop codons
    stop_codons = %w(tag tga taa)
    # sequence = Bio::Sequence::NA.new(MarkerSequence.gbol.first.sequence)
    # codons = sequence.codon_usage
    # stop_codons.each { |codon| puts codons[codon] }
  end

  def species_count_with_ms_count(species, marker_id, ms_count)
    species.where(individuals: { isolates: { marker_sequences: { marker: marker_id } } })
           .group(:id)
           .having('count(marker_sequences) > ?', ms_count).length
  end

  def species_count_with_exact_ms_count(species, marker_id, ms_count)
    species.where(individuals: { isolates: { marker_sequences: { marker: marker_id } } })
        .group(:id)
        .having('count(marker_sequences) = ?', ms_count).length
  end

  def get_information(marker_sequences, contigs)
    sequence_count = {}
    sequence_length_avg = {}
    sequence_length_min = {}
    sequence_length_max = {}
    reads_per_contig_avg = {}
    reads_per_contig_min = {}
    reads_per_contig_max = {}

    Marker.gbol.each do |marker|
      sequences = marker_sequences.where(marker_id: marker.id)
      contigs_marker = contigs.where(marker_id: marker.id)

      if sequences.size.positive?
        sequence_count[marker.name] = sequences.size
        sequence_length_avg[marker.name] = sequences.average('length(sequence)').to_f.round(2)
        sequence_length_min[marker.name] = sequences.select(:sequence, 'length(sequence)').where.not(:sequence => nil).order('length(sequence) asc').first.sequence.length
        sequence_length_max[marker.name] = sequences.select(:sequence, 'length(sequence)').where.not(:sequence => nil).order('length(sequence) desc').first.sequence.length
      end

      if contigs_marker.size.positive?
        primer_read_counts = contigs_marker.group(:id).count('primer_reads.id') #  TODO: only count assembled reads

        reads_per_contig_avg[marker.name] = (primer_read_counts.values.sum / primer_read_counts.values.size.to_f).round(2)
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

  # Returns the number of species in this family for which at least one marker sequence for this marker exists
  def completed_species_cnt(family, marker_id)
    count = 0

    family.species.includes(individuals: [isolates: :marker_sequences]).each do |s|
      has_ms = false
      s.individuals.each do |i|
        i.isolates.each do |iso|
          has_ms = iso.marker_sequences.where(:marker_id => marker_id).any? ? true : has_ms
        end
      end
      count += 1 if has_ms
    end

    count
  end
end
