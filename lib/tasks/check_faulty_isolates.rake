namespace :data do

  desc 'Check if faulty isolates in db have primer reads associated'
  task :check_faulty_isolates => :environment do
    puts 'Starting check for faulty isolates and plates...'

    plate_names = [*49..51]
    plate_names.concat [*60..73]

    plates_count = 0

    plate_names.each do | name |
      plates_count += 1 if PlantPlate.find_by_name(name.to_s)
    end

    if plates_count != plate_names.size
      puts "A different amount of plates was found than expected (#{plates_count} instead of #{plate_names.size})."
    else
      puts 'The same amount of plates was found as expected.'
    end

    gbol_numbers = [*4609..4896]
    gbol_numbers.concat [*5665..7008]

    isolates = Set.new
    contigs_cnt = 0
    ms_cnt = 0
    primer_reads = Set.new

    present = []

    gbol_numbers.each do | name |
      gbol_name = "gbol#{name.to_s}"

      isolate = Isolate.where("lab_nr ilike ?", gbol_name).first

      isolates.add? isolate if isolate
      present << name if isolate

      isolate&.contigs&.each do | contig |
        contigs_cnt += 1
        primer_reads.add? isolate if contig&.primer_reads&.size&.nonzero?
      end

      isolate&.marker_sequences&.each { ms_cnt += 1 }
    end

    not_found = gbol_numbers - present

    if gbol_numbers.size != isolates.size || gbol_numbers.size != contigs_cnt || gbol_numbers.size != ms_cnt
      puts "Expected: #{gbol_numbers.size}, Found: #{isolates.size} isolates, #{contigs_cnt} contigs and #{ms_cnt} marker sequences\n"
      puts 'The following isolates were not found:'
      not_found.each { |number| print "GBoL#{number}, " }
      puts "\n\n"
    else
      puts 'The same amount of isolates, contigs and marker sequences was found as expected.'
    end

    if primer_reads.size > 0
      puts "#{primer_reads.size} isolates with associated primer reads were found:"
      primer_reads.each {|isolate| print "#{isolate.lab_nr}, " }
      puts "\n\n"
    end

    puts 'Finished analysis.'
  end

  desc 'Delete incorrect isolate metadata'
  task :delete_incorrect_isolate_metadata => :environment do
    'Starting deletion of incorrect metadata...'

    # Delete incorrect specimen associations of isolates
    gbol_numbers = [*4609..4896]
    gbol_numbers.concat [*5665..7008]

    gbol_numbers.each do | name |
      gbol_name = "GBoL#{name.to_s}"
      isolate = Isolate.where("lab_nr ilike ?", gbol_name)

      if isolate.size > 1
        puts "More than one isolate with the name #{gbol_name} was found."
      else
        isolate = isolate.first
        isolate&.update(:individual_id => nil)
      end
    end

    puts 'All incorrect specimen associations were deleted.'
  end
end
