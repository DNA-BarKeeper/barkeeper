namespace :data do

  desc 'Do work statistics for <year>'
  task :work_statistics_yearly, [:year] => [:environment] do |t, args|
    range = Time.new(args[:year].to_i, 1, 1).all_year

    puts "Calculating activities for #{range.first.year}..."

    newly_verified_contigs = Contig.where(:verified_at => range).select(:id, :name)
    newly_verified_contigs_bonn_cnt = newly_verified_contigs.where("name ilike ?", "%gbol%").length
    newly_verified_contigs_berlin_cnt = newly_verified_contigs.where("name ilike ?", "%db%").length
    puts "Newly verified contigs: #{newly_verified_contigs.length} (total), #{newly_verified_contigs_bonn_cnt} (Bonn), #{newly_verified_contigs_berlin_cnt} (Berlin)"

    new_primer_reads = PrimerRead.where(:created_at => range).select(:id, :name)
    new_primer_reads_bonn_cnt = new_primer_reads.where("name ilike ?", "%gbol%").length
    new_primer_reads_berlin_cnt = new_primer_reads.where("name ilike ?", "%db%").length
    puts "Newly uploaded primer reads: #{new_primer_reads.length} (total), #{new_primer_reads_bonn_cnt} (Bonn), #{new_primer_reads_berlin_cnt} (Berlin)"

    new_isolates = Isolate.where(:created_at => range).select(:id, :lab_nr)
    new_isolates_bonn_cnt = new_isolates.where("lab_nr ilike ?", "%gbol%").length
    new_isolates_berlin_cnt = new_isolates.where("lab_nr ilike ?", "%db%").length
    puts "Newly created isolates: #{new_isolates.length} (total), #{new_isolates_bonn_cnt} (Bonn), #{new_isolates_berlin_cnt} (Berlin)"

    marker_sequences = MarkerSequence.where(:created_at => range).select(:id, :sequence, :name)
    base_count = marker_sequences.sum('length(sequence)')
    puts "Number of generated barcode sequences: #{marker_sequences.size}"
    puts "Sequenced base pairs: #{base_count}"
  end

  desc 'Do work statistics'
  task :work_statistics_total => [:environment] do |t, args|
    gbol_marker = Marker.gbol_marker

    puts "Calculating activities in total..."

    all_isolates_count = Isolate.all.size
    isolates_bonn_cnt = Isolate.where("lab_nr ilike ?", "%gbol%").size
    isolates_berlin_cnt = Isolate.where("lab_nr ilike ?", "%db%").size
    other_isolates_count = all_isolates_count - isolates_bonn_cnt - isolates_berlin_cnt
    puts "Number of isolates: #{all_isolates_count} (total), #{isolates_bonn_cnt} (Bonn), #{isolates_berlin_cnt} (Berlin), #{other_isolates_count} (not assigned to a lab)"

    sequence_cnt_per_marker = {}
    verified_count_per_marker = {}

    gbol_marker.each do |marker|
      sequence_cnt_per_marker[marker.name] = MarkerSequence.where(marker_id: marker.id).size
      verified_count_per_marker[marker.name] = Isolate.joins(contigs: :marker).where(contigs: { verified: true , marker_id: marker.id}).count('contigs.id')
    end

    puts "Number of barcode sequences per marker: #{sequence_cnt_per_marker}"
    puts "Isolates with verified contigs per marker: #{verified_count_per_marker}"

    # isolates_larger_three = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) > 3')
    # isolates_three = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences.where(marker.gbol_marker)) = 3')
    # isolates_two = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) = 2')
    # isolates_one = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) = 1')
    # isolates_zero = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) = 0').where(:marker_sequences.first.marker.gbol_marker)
  end
end
