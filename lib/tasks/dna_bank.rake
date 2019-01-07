# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

namespace :data do
  desc 'Get specimen info from DNA-Bank'
  task fetch_DNABank_info: :environment do
    # Asterales
    list_with_UnitIDs = 'DB 10140'.split("\n")
    counter = 1

    list_with_UnitIDs.each do |unit_id|
      break if counter > 1

      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{unit_id}</like></filter><count>false</count></search></request>"

      url = URI.parse(service_url)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
      doc = Nokogiri::XML(res.body)

      full_name = nil
      collector = nil
      locality = nil
      longitude = nil
      latitude = nil
      specimen_id = nil
      herbarium = nil

      begin
        unit = doc.at_xpath('//abcd21:Unit')

        specimen_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
        full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
        herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
        collector = unit.at_xpath('//abcd21:GatheringAgent').content
        locality = unit.at_xpath('//abcd21:LocalityText').content
        longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
        latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content

        puts counter
        puts unit_id + ':'

        puts specimen_id

        puts full_name if full_name

        # TODO: altervative base on gbol_nr that now also gets stored in DNA Bank

        puts "------------------\n"
      rescue StandardError
      end

      counter += 1
    end

    puts 'Done.'
  end

  # not to be used for regular background processes; only for manually crafted queries  where DNA-Bank number known and a specific range of DNA-Bank numbers manually entered below:
  desc 'Get range of DNA-Bank numbers related to GBOL and extract all specimen info and associated isolates (GBOL-Nrs.)'
  task get_all_DNABank: :environment do
    (10_000..12_350).each do |unit_id|
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>DB #{unit_id}</like></filter><count>false</count></search></request>"

      url = URI.parse(service_url)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end

      doc = Nokogiri::XML(res.body)

      full_name = nil
      collector = nil
      locality = nil
      longitude = nil
      latitude = nil
      specimen_id = nil
      herbarium = nil
      gbol_nr = nil

      begin
        unit = doc.at_xpath('//abcd21:Unit')

        specimen_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
        full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
        gbol_nr = unit.at_xpath('//abcd21:sampleDesignation').content
        herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
        collector = unit.at_xpath('//abcd21:GatheringAgent').content
        locality = unit.at_xpath('//abcd21:LocalityText').content
        longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
        latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
      rescue StandardError
      end

      puts unit_id

      puts specimen_id
      individual = if specimen_id
                     Individual.find_or_create_by(specimen_id: specimen_id)
                   else
                     Individual.create(specimen_id: '<no info available in DNA Bank>')
                   end

      individual.update(DNA_bank_id: "DB #{unit_id}") unless individual.DNA_bank_id

      puts collector
      individual.update(collector: collector.strip) if collector

      puts locality
      individual.update(locality: locality) if locality

      puts longitude
      individual.update(longitude: longitude) if longitude

      puts latitude
      individual.update(latitude: latitude) if latiude

      puts herbarium
      individual.update(herbarium: herbarium) if herbarium

      if full_name
        regex = /^(\w+\s+\w+)/
        matches = full_name.match(regex)
        if matches
          species_component = matches[1]

          puts species_component

          sp = individual.species

          if sp.nil?
            sp = Species.find_or_create_by(species_component: species_component)
            individual.update(species: sp)
          end
        end
      end

      # TODO: make case insensitive match:

      next unless gbol_nr
      # inconsistent in DNABank: sometimes lowercase, sometimes uppercase o in GBOL:
      gbol_nr[2] = 'o' if gbol_nr[2] == 'O'
      puts gbol_nr
      isolate = Isolate.find_or_create_by(lab_nr: gbol_nr)
      isolate.update(individual: individual)
    end

    puts 'Done.'
  end

  desc 'Get all GBOL-Nrs that have no specimen assigned and extract all specimen info from DNABank, if corresponding GBOL-Nr exists there.'
  task get_DNABank_by_gbol_nr: :environment do
    # get all gbol-nr where no specimen
    Isolate.where(individual: nil).where('isolates.lab_nr ILIKE ?', '%GBOL%').each do |i|
      # for each number, do a call for GBOL and GBoL versions:

      gbol_nr = i.lab_nr

      gbol_nr_1 = gbol_nr

      gbol_nrs = []
      gbol_nrs[0] = gbol_nr_1

      if gbol_nr_1[2] == 'O'
        gbol_nr_2 = gbol_nr_1.clone
        gbol_nr_2[2] = 'o'
        gbol_nrs[1] = gbol_nr_2
      else
        gbol_nr_2 = gbol_nr_1.clone
        gbol_nr_2[2] = 'O'
        gbol_nrs[1] = gbol_nr_2
      end

      gbol_nrs[1] = gbol_nr_2

      gbol_nrs.each do |gbol_nr|
        puts "Query for #{gbol_nr}...\n"

        service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{gbol_nr}</like></filter><count>false</count></search></request>"

        url = URI.parse(service_url)
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end

        doc = Nokogiri::XML(res.body)

        full_name = nil
        collector = nil
        locality = nil
        longitude = nil
        latitude = nil
        specimen_id = nil
        herbarium = nil

        begin
          unit = doc.at_xpath('//abcd21:Unit')
          unit_id = doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content # = DNA Bank nr
          specimen_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
          full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
          herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
          collector = unit.at_xpath('//abcd21:GatheringAgent').content
          locality = unit.at_xpath('//abcd21:LocalityText').content
          longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
          latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
        rescue StandardError
        end

        puts unit_id if unit_id

        next unless specimen_id

        puts specimen_id

        individual = Individual.find_or_create_by(specimen_id: specimen_id)

        if unit_id
          puts unit_id
          individual.update(DNA_bank_id: unit_id)
          begin
            individual.isolates.each do |iso|
              iso.update(dna_bank_id: unit_id)
            end
          rescue StandardError
          end
        end

        puts collector
        individual.update(collector: collector.strip) if collector

        puts locality
        individual.update(locality: locality) if locality

        puts longitude
        individual.update(longitude: longitude) if longitude

        puts latitude
        individual.update(latitude: latitude) if latitude

        puts herbarium
        individual.update(herbarium: herbarium) if herbarium

        if full_name

          regex = /^(\w+\s+\w+)/
          matches = full_name.match(regex)
          if matches
            species_component = matches[1]

            puts species_component

            sp = individual.species

            if sp.nil?
              sp = Species.find_or_create_by(species_component: species_component)
              individual.update(species: sp)
            end
          end

        end

        isolate = Isolate.where(lab_nr: i.lab_nr).first

        isolate&.update(individual: individual)

        break # no need to try alternative "gbol" spelling if already found a match
      end
    end

    puts 'Done.'
  end

  desc 'Get all specimens with <no info available in DNA Bank> as specimen id, try to get an isolate from this specimen with a gbol-nr, and extract all specimen info from DNABank, if corresponding GBOL-Nr exists there.'
  task get_DNABank_by_specimen_without_id: :environment do
    # get all gbol-nr where such specimen
    Individual.where(specimen_id: '<no info available in DNA Bank>').each do |individual|
      # for each number, do a call for GBOL and GBoL versions:

      begin
        gbol_nr = individual.isolates.first.lab_nr

        gbol_nr_1 = gbol_nr

        gbol_nrs = []
        gbol_nrs[0] = gbol_nr_1

        if gbol_nr_1[2] == 'O'
          gbol_nr_2 = gbol_nr_1.clone
          gbol_nr_2[2] = 'o'
          gbol_nrs[1] = gbol_nr_2
        else
          gbol_nr_2 = gbol_nr_1.clone
          gbol_nr_2[2] = 'O'
          gbol_nrs[1] = gbol_nr_2
        end

        gbol_nrs[1] = gbol_nr_2

        gbol_nrs.each do |gbol_nr|
          puts "Query for #{gbol_nr}...\n"

          service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{gbol_nr}</like></filter><count>false</count></search></request>"

          url = URI.parse(service_url)
          req = Net::HTTP::Get.new(url.to_s)
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end

          doc = Nokogiri::XML(res.body)

          full_name = nil
          collector = nil
          locality = nil
          longitude = nil
          latitude = nil
          specimen_id = nil
          herbarium = nil

          begin
            unit = doc.at_xpath('//abcd21:Unit')
            unit_id = doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content # = DNA Bank nr
            specimen_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
            full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
            herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
            collector = unit.at_xpath('//abcd21:GatheringAgent').content
            locality = unit.at_xpath('//abcd21:LocalityText').content
            longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
            latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
          rescue StandardError
            # ignored
          end

          puts unit_id if unit_id

          next unless specimen_id

          individual.update(specimen_id: specimen_id)

          puts specimen_id

          if unit_id
            puts unit_id
            individual.update(DNA_bank_id: unit_id)
          end

          puts collector
          individual.update(collector: collector.strip) if collector

          puts locality
          individual.update(locality: locality) if locality

          puts longitude
          individual.update(longitude: longitude) if longitude

          puts latitude
          individual.update(latitude: latitude) if latitude

          puts herbarium
          individual.update(herbarium: herbarium) if herbarium

          if full_name

            regex = /^(\w+\s+\w+)/
            matches = full_name.match(regex)
            if matches
              species_component = matches[1]

              puts species_component

              sp = individual.species

              if sp.nil?
                sp = Species.find_or_create_by(species_component: species_component)
                individual.update(species: sp)
              end
            end

          end

          isolate = Isolate.where(lab_nr: i.lab_nr).first

          isolate&.update(individual: individual)

          break # no need to try alternative "gbOl" spelling if already found a match
        end
      rescue StandardError
        # ignored
      end
    end

    puts 'Done.'
  end

  desc 'For given GBOL-Nrs, extract all specimen info from DNABank, if corresponding GBOL-Nr exists there.'
  task reset_DNABank_by_gbol_nr: :environment do
    outputstr = "Isolate ID\tGBOL-Nr (Lab-Nr)\tcurrent DNA-Bank-Nr\tcurrent specimen\tcurrent species\tfuture DNA-Bank-Nr\tfuture specimen\tfuture species\n"

    c = Isolate.all.count
    ctr = 1

    Isolate.all.each do |i|
      # Isolate.find([11302, 11317, 9986]).each do |i|
      progress = "#{ctr} / #{c}" + "\r"
      puts progress

      specimen = ''
      species = ''
      if i.individual
        specimen = i.individual.specimen_id
        species = i.individual.species.species_component if i.individual.species
      end

      gbol_nr = i.lab_nr

      unit = nil
      unit_id = nil
      specimen_id = nil
      full_name = nil
      herbarium = nil
      collector = nil
      locality = nil
      longitude = nil
      latitude = nil

      puts "Query for #{gbol_nr}..."

      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{gbol_nr}</like></filter><count>false</count></search></request>"

      url = URI.parse(service_url)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end

      doc = Nokogiri::XML(res.body)

      begin
        unit = doc.at_xpath('//abcd21:Unit')
        unit_id = doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content # = DNA Bank nr
        specimen_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
        full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
        herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
        collector = unit.at_xpath('//abcd21:GatheringAgent').content
        locality = unit.at_xpath('//abcd21:LocalityText').content
        longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
        latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
      rescue StandardError
        # puts "Extraction not possible."
      end

      puts

      if unit_id && i.dna_bank_id
        if unit_id.gsub(/\s+/, '') == i.dna_bank_id.gsub(/\s+/, '')
          # don't output anything - correction from upcoming DNABank query will not change anything
        else
          outputstr += "#{i.id}\t#{i.lab_nr}\t#{i.dna_bank_id}\t#{specimen}\t#{species}\t"
          outputstr += "#{unit_id}\t" # future dna_bank_id

          if specimen_id
            outputstr += "#{specimen_id}\t" # future specimen_id
            outputstr += "#{full_name}\n" if full_name
          end
        end
      end

      ctr += 1
    end

    puts "#{outputstr}\n\nDone."
  end
end
