require 'net/http'
require 'nokogiri'


namespace :data do

  desc 'Do work statistics'
  task :work_statistics => [:environment] do |t, args|
    # args.with_defaults(:range => Time.now.beginning_of_year..Time.now)
    # range = eval args[:range]
    range = 1.year.ago.all_year # 2017

    puts "Calculating activities from #{range.begin.to_formatted_s(:db)} until #{range.end.to_formatted_s(:db)}..."

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

    all_isolates_count = Isolate.all.size
    isolates_bonn_cnt = Isolate.where("lab_nr ilike ?", "%gbol%").size
    isolates_berlin_cnt = Isolate.where("lab_nr ilike ?", "%db%").size
    other_isolates_count = all_isolates_count - isolates_bonn_cnt - isolates_berlin_cnt

    puts "Calculating activities in total..."

    puts "Number of isolates: #{all_isolates_count} (total), #{isolates_bonn_cnt} (Bonn), #{isolates_berlin_cnt} (Berlin), #{other_isolates_count} (not assigned to a lab)"

    Marker.gbol_marker.each do |marker|
      sequence_cnt = MarkerSequence.where(:marker_id => marker.id).length
      puts "#{sequence_cnt} sequences exist for marker '#{marker.name}'"
    end

    verified_count_per_marker = Hash.new
    Marker.gbol_marker.each { |marker| verified_count_per_marker[marker.name] = 0 }

    Isolate.all.each do |isolate|
      isolate.contigs.each do |c|

        if c.verified && c.marker.is_gbol
          verified_count_per_marker[c.marker.name] += 1
        end

      end
    end

    puts "Isolates with verified contigs per marker: #{verified_count_per_marker}"

    # isolates_larger_three = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) > 3')
    # isolates_three = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences.where(marker.gbol_marker)) = 3')
    # isolates_two = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) = 2')
    # isolates_one = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) = 1')
    # isolates_zero = Isolate.joins(:marker_sequences).group('isolates.id').having('count(marker_sequences) = 0').where(:marker_sequences.first.marker.gbol_marker)
  end
end
