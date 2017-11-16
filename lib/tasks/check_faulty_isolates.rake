require 'net/http'
require 'nokogiri'


namespace :data do

  desc "Check if faulty isolates in db have primer reads associated"
  task :check_faulty_isolates => :environment do
    puts "Starting check of faulty isolates and plates..."

    plate_names = [*49..51]
    plate_names.concat [*60..73]

    plates_count = 0

    plate_names.each do | name |
      plates_count += 1 if PlantPlate.find_by_name(name.to_s)
    end

    if plates_count != plate_names.size
      puts "A different amount of plates was found than expected (#{plates_count} instead of #{plate_names.size})."
    else
      puts "The same amount of plates was found as expected."
    end

    gbol_numbers = [*4609..4896]
    gbol_numbers.concat [*5665..7008]

    isolates = Set.new
    contigs_cnt = 0
    ms_cnt = 0
    primer_reads = Set.new

    gbol_numbers.each do | name |
      gbol_name = "gbol#{name.to_s}"

      isolate = Isolate.where("lab_nr ilike ?", gbol_name).first

      isolates.add? isolate if isolate

      isolate&.contigs&.each do | contig |
        contigs_cnt += 1
        primer_reads.add? isolate if contig&.primer_reads&.size&.nonzero?
      end

      isolate&.marker_sequences&.each { ms_cnt += 1 }
    end

    if gbol_numbers.size != isolates.size || gbol_numbers.size != contigs_cnt || gbol_numbers.size != ms_cnt
      puts "Expected: #{gbol_numbers.size}, Found: #{isolates.size} isolates, #{contigs_cnt} contigs and #{ms_cnt} marker sequences"
      puts "The following isolates were not found:"
      isolates.each { |isolate| print "#{isolate.lab_nr}, " }
      puts ""
    else
      puts "The same amount of isolates, contigs and marker sequences was found as expected."
    end

    if primer_reads.size > 0
      puts "#{primer_reads.size} isolates with associated primer reads were found:"
      primer_reads.each {|isolate| print "#{isolate.lab_nr}, " }
      puts ""
    end

    puts "Finished analysis."
  end

  desc "Delete faulty isolates and associated elements"
  task :delete_faulty_isolates => :environment do
    plate_names = [*49..51]
    plate_names.concat [*60..73]

    plate_names.each do | name |
      PlantPlate.find_by_name(name.to_s).destroy!
    end

    gbol_numbers = [*4609..4896]
    gbol_numbers.concat [*5665..7008]

    gbol_numbers.each do | name |
      gbol_name = "GBoL#{name.to_s}"
      isolate = Isolate.where("lab_nr ilike ?", gbol_name).first

      isolate.contigs.each do | contig |
        contig.issues.each { |issue| issue.destroy! }
        contig.partial_cons.each { |p_con| p_con.destroy! }
        contig.destroy!
      end

      isolate.marker_sequences.each { |ms| ms.destroy! }
    end

    puts "All faulty isolates, plates and connected data were successfully destroyed."

  end
end
