namespace :data do

  #TODO: scary loop in which arr.elements are deleted - fix!

  desc "Merge multiple copies of same isolate into one with all associations & attributes"

  task :merge_duplicate_isolates => :environment do

    # get list w duplicates
    a=[]
    Isolate.select("lab_nr").all.each do |i|
      a << i.lab_nr
    end
    d=a.select{ |e| a.count(e) > 1 }.uniq


    # iterate over duplicate lab_nrs:
    d.each do |duplicate_isolate|

      #get  all members of given duplicate list:
      dups=Isolate.includes(:individual => :species).where(:lab_nr => duplicate_isolate)

      #get first
      first_dup=dups.first

      #get all others and compare to first
      (1..dups.count-1).each do |i|
        curr_dup= dups[i]
        puts "#{curr_dup.lab_nr} (#{curr_dup.id})  vs #{first_dup.lab_nr} ( #{first_dup.id} ):"

        if curr_dup.individual
          first_dup.update(:individual => curr_dup.individual)
        end

        if curr_dup.marker_sequences.count > 0
          curr_dup.marker_sequences.each do |m|
            first_dup.marker_sequences << m
          end
        end

        if curr_dup.contigs.count >0
          curr_dup.contigs.each do |c|
            first_dup.contigs << c
          end
        end

        curr_dup.destroy

      end

      puts ""
    end

    puts "Done."

  end

end