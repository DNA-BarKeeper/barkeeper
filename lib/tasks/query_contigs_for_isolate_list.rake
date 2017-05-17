require 'net/http'
require 'nokogiri'

namespace :data do

  desc "For given GBOL-Nrs, check which contigs exist."

  task :query_contigs_for_isolate_list => :environment do

    outputstr=  "Isolate ID\tGBOL-Nr (Lab-Nr)\tcurrent DNA-Bank-Nr\tcurrent specimen\tcurrent species\tfuture DNA-Bank-Nr\tfuture specimen\tfuture species\n"


    list_with_gbol_nrs="GBoL2691
GBoL2694
GBoL2696
GBoL2711
GBoL2718
GBoL2695
GBoL2724
GBoL2726
GBoL2729
GBoL2731
GBoL2732
GBoL2740
GBoL2744
GBoL2748
GBoL2770
GBoL2776
GBoL2759
GBoL2787
GBoL2815
GBoL2819
GBoL2790
GBoL2846
GBoL2834
GBoL2593
GBoL2630
GBoL2631
GBoL2641
GBoL2649
GBoL2658
GBoL2666
GBoL2672
GBoL2682
GBoL3650
GBoL3652
GBoL3658
GBoL3661
GBoL3662
GBoL3697
GBoL3699
GBoL3700
GBoL3703
GBoL3704
GBoL3705
GBoL3727
GBoL3707
GBoL3701
GBoL3739
GBoL3740
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