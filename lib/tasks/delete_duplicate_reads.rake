namespace :data do

  desc "destroy duplicate reads from non-verified contigs"

  task :destroy_duplicate_reads => :environment do

    # get list w duplicate reads FROM NON-VERIFIED CONTIGS ONLY
    a=[]

    PrimerRead.select("name").contig_not_verified.each do |i|
        a << i.name
    end

    d=a.select{ |e| a.count(e) > 1 }.uniq

    # iterate over duplicate read names:

    d.each do |duplicate|

      # puts "\n"
      #get  all members of given duplicate list: # IGNORE THOSE FROM VERIFIED CONTIGS IN THIS DUPLICATE LIST

      dups=PrimerRead.contig_not_verified.where(:name => duplicate)

      #get first

      first_dup=dups.first

      # puts "will keep #{first_dup.name} (#{first_dup.id})"

      #get all others

      #TODO: scary loop in which arr.elements are deleted (?) - fix!

      (1..dups.count-1).each do |i|

        curr_dup= dups[i]

        # puts "will destroy #{curr_dup.name} (#{curr_dup.id})"

        curr_dup.destroy

      end

      puts "\n"
    end

    puts "Done."

  end

end