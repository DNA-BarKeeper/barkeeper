require 'net/http'
require 'nokogiri'

namespace :data do

  desc "For given GBOL-Nrs, check which contigs exist."

  task :query_contigs_for_isolate_list => :environment do

    outputstr=  "Isolate ID\tGBOL-Nr (Lab-Nr)\tcurrent DNA-Bank-Nr\tcurrent specimen\tcurrent species\tfuture DNA-Bank-Nr\tfuture specimen\tfuture species\n"


    list_with_gbol_nrs="GBoL3457
GBoL3467
GBoL3459
GBoL3474
GBoL3472
GBoL3476
GBoL3477
GBoL3481
GBoL3482
GBoL3505
GBoL3517
  GBoL3484
GBoL3521
GBoL3522
GBoL3523
GBoL3535
GBoL3537
GBoL3554
GBoL3568
GBoL3569
GBoL3573
GBoL3571
GBoL3588
GBoL3589
GBoL3590
GBoL3591
GBoL3592
GBoL3593
GBoL3594
GBoL3595
GBoL3596
GBoL3597
GBoL3603
GBoL3613
GBoL3615
GBoL3616
GBoL3617
GBoL3618
GBoL3619
GBoL3641
GBoL3625
GBoL3626
GBoL3627
GBoL3635
GBoL3636
GBoL3606
GBoL3637
GBoL3541
".split("\n")

    list_with_gbol_nrs.each do |i|

      outputstr += "#{i}\t"


      isolate=Isolate.where(:lab_nr => i).first


      isolate.contigs.each do |c|

        if c.verified_at.nil?
          outputstr += "#{c.marker.name} "
        else
          outputstr += "#{c.marker.name} (verified)"
        end

        outputstr += "\t"

      end

      outputstr+="\n"


    end

    puts outputstr

    puts

    puts "Done."

  end

end