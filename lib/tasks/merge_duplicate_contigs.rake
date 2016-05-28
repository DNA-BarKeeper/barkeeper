namespace :data do

  #TODO: scary loop in which arr.elements are deleted - fix!

  desc "Merge multiple copies of same contigs into one with all associations & attributes"

  task :merge_duplicate_contigs => :environment do

    # get list w duplicates
    a=[]
    Contig.select("name").each do |i|
      a << i.name
    end
    d=a.select{ |e| a.count(e) > 1 }.uniq

    # iterate over duplicate lab_nrs:
    d.each do |duplicate|

      #get  all members of given duplicate list:
      dups=Contig.where(:name => duplicate).where(:verified_by => nil)

      if dups.count > 1

        #get first
        first_dup=dups.first

        #get all others and compare to first
        (1..dups.count-1).each do |i|
          curr_dup= dups[i]

          puts "#{curr_dup.name} (#{curr_dup.id})  vs #{first_dup.name} ( #{first_dup.id} ):"

          if curr_dup.isolate
            first_dup.update(:isolate => curr_dup.isolate)
          end

          if curr_dup.marker
            first_dup.update(:marker => curr_dup.marker)
          end

          if curr_dup.marker_sequence
            first_dup.update(:marker_sequence => curr_dup.marker_sequence)
          end

          if curr_dup.partial_cons.count > 0
            curr_dup.partial_cons.each do |m|
              first_dup.partial_cons << m
            end
          end

          if curr_dup.primer_reads.count >0
            curr_dup.primer_reads.each do |c|
              first_dup.primer_reads << c
            end
          end

          curr_dup.destroy

        end
      end

      puts ""
    end

    puts "Done."

  end

end