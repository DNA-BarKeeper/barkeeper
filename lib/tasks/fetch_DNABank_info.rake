require 'net/http'
require 'nokogiri'


namespace :data do

  desc "Get specimen info from DNA-Bank"

  task :fetch_DNABank_info => :environment do

    list_with_UnitIDs=[]

    Isolate.where('lab_nr ILIKE ?', "DB%").each do |isolate|

      regex = /^DB(\d+)$/
      matches = isolate.lab_nr.match(regex)
      number_component = matches[1]

      list_with_UnitIDs << "DB #{number_component}"

    end

    ctr=1

    list_with_UnitIDs.each do |unit_id|

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
      gbol_nr=nil

      begin
        unit = doc.at_xpath('//abcd21:Unit')

        specimen_id=unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
        full_name= unit.at_xpath('//abcd21:FullScientificNameString').content
        gbol_nr=unit.at_xpath('//abcd21:sampleDesignation').content
        herbarium=unit.at_xpath('//abcd21:SourceInstitutionCode').content
        collector= unit.at_xpath('//abcd21:GatheringAgent').content
        locality=unit.at_xpath('//abcd21:LocalityText').content
        longitude=unit.at_xpath('//abcd21:LongitudeDecimal').content
        latitude=unit.at_xpath('//abcd21:LatitudeDecimal').content
      rescue
      end

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

          puts species_component

          sp=individual.species

          if sp.nil?
            sp= Species.find_or_create_by(:species_component => specimen_id)
            individual.update(:species=>sp)
          end
        end

      end

      db_nr=unit_id.gsub(' ','')
      puts db_nr

      #todo: altervative base on gbol_nr that now also gets stored in DNA Bank
      isolate=Isolate.where(:lab_nr => db_nr).first

      isolate.update(:individual => individual)

      puts

      ctr+=1

    end

    # puts list_with_UnitIDs

    puts "Done."

  end

end