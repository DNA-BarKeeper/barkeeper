require 'net/http'
require 'nokogiri'

namespace :data do

  desc "For given GBOL-Nrs, extract all specimen info from DNABank, if corresponding GBOL-Nr exists there."

  task :reset_DNABank_by_gbol_nr => :environment do

    outputstr=  "Isolate ID\tGBOL-Nr (Lab-Nr)\tcurrent DNA-Bank-Nr\tcurrent specimen\tcurrent species\tfuture DNA-Bank-Nr\tfuture specimen\tfuture species\n"

    c=Isolate.all.count
    ctr=1

    Isolate.all.each do |i|
    # Isolate.find([10131]).each do |i|
      progress = "#{ctr} / #{c}" + "\r"
      puts progress

      specimen=""
      species=""
      if i.individual
        specimen=i.individual.specimen_id
        if i.individual.species
          species=i.individual.species.species_component
        end
      end

      # for each number, do a call for GBOL and GBoL versions:

      gbol_nr=i.lab_nr

      gbol_nr_1=gbol_nr

      gbol_nrs=[]
      gbol_nrs[0] = gbol_nr_1

      if gbol_nr_1[2]=='O'
        gbol_nr_2=gbol_nr_1.clone
        gbol_nr_2[2]='o'
        gbol_nrs[1]=gbol_nr_2
      else
        gbol_nr_2=gbol_nr_1.clone
        gbol_nr_2[2]='O'
        gbol_nrs[1]=gbol_nr_2
      end

      gbol_nrs[1] = gbol_nr_2

      gbol_nrs.each do |gbol_nr|

        # puts "Query for #{gbol_nr}...\n"

        service_url="http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{gbol_nr}</like></filter><count>false</count></search></request>"

        url = URI.parse(service_url)
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) { |http|
          http.request(req)
        }

        doc= Nokogiri::XML(res.body)

        unit = nil
        unit_id=nil
        specimen_id=nil
        full_name= nil
        herbarium=nil
        collector= nil
        locality=nil
        longitude=nil
        latitude=nil

        begin
          unit = doc.at_xpath('//abcd21:Unit')
          unit_id=doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content # = DNA Bank nr
          specimen_id=unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
          full_name= unit.at_xpath('//abcd21:FullScientificNameString').content
          herbarium=unit.at_xpath('//abcd21:SourceInstitutionCode').content
          collector= unit.at_xpath('//abcd21:GatheringAgent').content
          locality=unit.at_xpath('//abcd21:LocalityText').content
          longitude=unit.at_xpath('//abcd21:LongitudeDecimal').content
          latitude=unit.at_xpath('//abcd21:LatitudeDecimal').content

        rescue

          # puts "Extraction not possible."

        end

        if unit_id

          if unit_id.gsub(/\s+/, "") == i.dna_bank_id
            break #don't do anything - DNABank query will not change anything
          else
            outputstr+=  "#{i.id}\t#{i.lab_nr}\t#{i.dna_bank_id}\t#{specimen}\t#{species}\t"
            outputstr+= "#{unit_id}\t" #future dna_bank_id
          end

          if specimen_id

            outputstr+= "#{specimen_id}\t" #future specimen_id

            # individual = Individual.find_or_create_by(:specimen_id => specimen_id)
            #
            # if unit_id
            #   # puts unit_id
            #   #TODO: should individual AND isolate both store DNA-Bank-ID? (Problem that DNABank does not seem to model isolates and specimens separately)
            #   individual.update(:DNA_bank_id => unit_id )
            #   begin
            #     individual.isolates.each do |iso|
            #       iso.update(:dna_bank_id => unit_id)
            #     end
            #   rescue
            #   end
            # end
            #
            # # puts collector
            # if collector
            #   individual.update(:collector => collector.strip)
            # end
            #
            # puts locality
            # if locality
            #   individual.update(:locality => locality)
            # end
            #
            # puts longitude
            # if longitude
            #   individual.update(:longitude => longitude)
            # end
            #
            # puts latitude
            # if latitude
            #   individual.update(:latitude => latitude)
            # end
            #
            # puts herbarium
            # if herbarium
            #   individual.update(:herbarium => herbarium)
            # end

            if full_name

              # regex = /^(\w+\s+\w+)/
              # matches = full_name.match(regex)
              # if matches
              #   species_component = matches[1]



                # sp=individual.species
                #
                # if sp.nil?
                #   #todo: unify species_component and composed name
                # end
                #   sp= Species.find_or_create_by(:species_component => species_component)
                #   individual.update(:species => sp)
                # end
              # end

              outputstr+= "#{full_name}\n"

            end

            # isolate = Isolate.where(:lab_nr => i.lab_nr).first
            #
            # if isolate
            #   isolate.update(:individual => individual)
            # end

          end

          break # no need to try alternative "gbol" spelling if already found a matching unit_id

        end

      end

      ctr=ctr+1

    end

    puts outputstr

    puts

    puts "Done."

  end

end