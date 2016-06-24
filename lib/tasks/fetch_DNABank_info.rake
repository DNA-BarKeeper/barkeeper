require 'net/http'
require 'nokogiri'


namespace :data do

  desc "Get specimen info from DNA-Bank"

  task :fetch_DNABank_info => :environment do

    # list_with_UnitIDs=[]

    # Isolate.where('lab_nr ILIKE ?', "DB%").each do |isolate|
    #
    #   regex = /^DB(\d+)$/
    #   matches = isolate.lab_nr.match(regex)
    #   number_component = matches[1]
    #
    #   list_with_UnitIDs << "DB #{number_component}"
    #
    # end

    #Poales
    list_with_UnitIDs="DB 0567
    DB 0618
    DB 0689
    DB 0703
    DB 1088
    DB 1415
    DB 1433
    DB 1460
    DB 1473
    DB 1474
    DB 1479
    DB 1481
    DB 1484
    DB 1510
    DB 1545
    DB 1547
    DB 1615
    DB 1667
    DB 1670
    DB 1687
    DB 1689
    DB 1692
    DB 1696
    DB 1719
    DB 1990
    DB 2017
    DB 2029
    DB 2053
    DB 2082
    DB 2104
    DB 2106
    DB 2124
    DB 2142
    DB 2156
    DB 2160
    DB 2167
    DB 2170
    DB 2171
    DB 2172
    DB 2174
    DB 2175
    DB 2185
    DB 2188
    DB 2219
    DB 2221
    DB 2222
    DB 2226
    DB 2227
    DB 2231
    DB 2239
    DB 2242
    DB 2246
    DB 2266
    DB 2274
    DB 2276
    DB 2287
    DB 2289
    DB 2294
    DB 2305
    DB 2344
    DB 2346
    DB 2347
    DB 2348
    DB 2352
    DB 2356
    DB 2359
    DB 2360
    DB 2361
    DB 2369
    DB 2372
    DB 2375
    DB 2383
    DB 2448
    DB 2451
    DB 2452
    DB 2459
    DB 2461
    DB 2470
    DB 2471
    DB 2482
    DB 2486
    DB 2487
    DB 2488
    DB 2489
    DB 2490
    DB 2495
    DB 2505
    DB 2540
    DB 2548
    DB 2549
    DB 2552
    DB 2559
    DB 2560
    DB 2561
    DB 2562
    DB 2601
    DB 2636
    DB 2645
    DB 2660
    DB 2804
    DB 2814
    DB 2837
    DB 2845
    DB 2886
    DB 2888
    DB 2894
    DB 2903
    DB 2915
    DB 2916
    DB 2919
    DB 2920
    DB 2933
    DB 2936
    DB 2938
    DB 2939
    DB 2940
    DB 2942
    DB 2983
    DB 3020
    DB 3635
    DB 3643
    DB 3682
    DB 3686
    DB 3693
    DB 3694
    DB 3759
    DB 3890
    DB 3902
    DB 3926
    DB 3935
    DB 3943
    DB 3956
    DB 3967
    DB 3982
    DB 3988
    DB 3998
    DB 4074
    DB 4082
    DB 4834
    DB 4835
    DB 4837
    DB 4883
    DB 5605
    DB 5610
    DB 5790
    DB 5794
    DB 5847
    DB 5883
    DB 5890
    DB 5948
    DB 5949
    DB 5952
    DB 5953
    DB 5957
    DB 5988
    DB 5992
    DB 5993
    DB 5994
    DB 6009
    DB 6944
    DB 7088
    DB 7097
    DB 7098
    DB 7204
    DB 7216
    DB 7349
    DB 7351
    DB 7358
    DB 7360
    DB 7361
    DB 7555
    DB 7577
    DB 7579
    DB 7585
    DB 7589
    DB 7626
    DB 7627
    DB 7629
    DB 7637
    DB 7640
    DB 7641".split("\n")

    ctr=1

    list_with_UnitIDs.each do |unit_id|

      if ctr > 10
        break
      end

      service_url="http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{unit_id}</like></filter><count>false</count></search></request>"

      url = URI.parse(service_url)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }

      doc= Nokogiri::XML(res.body)

      full_name=nil
      collector=nil
      locality=nil
      longitude=nil
      latitude=nil
      specimen_id=nil
      herbarium=nil
      # gbol_nr=nil

      begin
        unit = doc.at_xpath('//abcd21:Unit')

        specimen_id=unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
        full_name= unit.at_xpath('//abcd21:FullScientificNameString').content
        # gbol_nr=unit.at_xpath('//abcd21:sampleDesignation').content
        herbarium=unit.at_xpath('//abcd21:SourceInstitutionCode').content
        collector= unit.at_xpath('//abcd21:GatheringAgent').content
        locality=unit.at_xpath('//abcd21:LocalityText').content
        longitude=unit.at_xpath('//abcd21:LongitudeDecimal').content
        latitude=unit.at_xpath('//abcd21:LatitudeDecimal').content

        puts ctr
        puts unit_id+':'

        puts specimen_id
        if specimen_id
          individual = Individual.find_or_create_by(:specimen_id => specimen_id)
        else
          individual = Individual.create(:specimen_id => "<no info available in DNA Bank>")
        end


        puts collector
        if collector
          individual.update(:collector => collector.strip)
        end


        puts locality
        if locality
          individual.update(:locality => locality)
        end

        puts longitude
        if longitude
          individual.update(:longitude => longitude)
        end

        puts latitude
        if latitude
          individual.update(:latitude => latitude)
        end

        puts herbarium
        if herbarium
          individual.update(:herbarium => herbarium)
        end


        if full_name
          puts full_name

          regex = /^(\w+\s\w+)/
          matches = full_name.match(regex)
          if matches
            species_component = matches[1]



            sp=individual.species

            sp= Species.find_or_create_by(:species_component => species_component)
            individual.update(:species => sp)

            puts sp.species_component

          end

        end

        db_nr=unit_id.gsub(' ','')

        # puts db_nr

        #todo: altervative base on gbol_nr that now also gets stored in DNA Bank
        isolate=Isolate.find_or_create_by(:lab_nr => db_nr)
        #
        isolate.update(:individual => individual)

        puts "------------------\n"

      rescue
        Issue.find_or_create_by(:title => "No match in DNABank found for #{unit_id}")
      end

      ctr+=1

    end

    # puts list_with_UnitIDs

    puts "Done."

  end

end