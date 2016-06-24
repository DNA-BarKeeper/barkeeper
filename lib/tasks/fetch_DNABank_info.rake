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

    #Asterales
    list_with_UnitIDs="DB 0060
DB 0061
DB 0064
DB 0065
DB 0066
DB 0068
DB 0070
DB 0071
DB 0072
DB 0074
DB 0076
DB 0079
DB 0080
DB 0081
DB 0082
DB 0131
DB 0138
DB 0139
DB 0147
DB 0150
DB 0153
DB 0154
DB 0158
DB 0289
DB 0587
DB 0600
DB 0769
DB 0852
DB 0918
DB 0919
DB 1058
DB 1070
DB 1073
DB 1084
DB 1361
DB 1374
DB 1413
DB 1430
DB 1432
DB 1434
DB 1435
DB 1439
DB 1442
DB 1452
DB 1459
DB 1464
DB 1469
DB 1482
DB 1488
DB 1494
DB 1499
DB 1507
DB 1520
DB 1522
DB 1591
DB 1616
DB 1718
DB 1754
DB 1761
DB 1766
DB 1767
DB 1768
DB 1771
DB 1802
DB 1815
DB 2158
DB 2183
DB 2184
DB 2191
DB 2199
DB 2228
DB 2260
DB 2261
DB 2262
DB 2340
DB 2345
DB 2350
DB 2446
DB 2474
DB 2510
DB 2531
DB 2536
DB 2641
DB 2816
DB 2817
DB 2823
DB 2880
DB 2892
DB 2900
DB 2902
DB 2909
DB 2912
DB 2925
DB 2953
DB 2992
DB 3039
DB 3634
DB 3637
DB 3640
DB 3650
DB 3715
DB 3748
DB 3756
DB 3769
DB 3770
DB 3941
DB 3975
DB 3976
DB 4879
DB 4880
DB 5119
DB 5334
DB 5335
DB 5351
DB 5352
DB 5353
DB 5358
DB 5492
DB 5495
DB 5566
DB 5623
DB 5657
DB 5666
DB 5746
DB 5753
DB 5756
DB 5760
DB 5811
DB 5814
DB 5818
DB 5851
DB 5867
DB 5947
DB 5950
DB 5981
DB 6022
DB 7008
DB 7113
DB 7206
DB 7340
DB 7355
DB 7565
DB 7604
DB 7922
DB 7933
DB 7939
DB 7960
DB 7961
DB 7970
DB 8013
DB 8100".split("\n")

    ctr=1

    list_with_UnitIDs.each do |unit_id|

      # if ctr > 10
      #   break
      # end

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