module ApplicationHelper
  require 'net/http'
  require 'nokogiri'

  def display_base_errors(resource)
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end


  def show_val_errors resource

    if (resource.errors.any?)

      compiledMsg = pluralize(resource.errors.count, "error") + ': '

      resource.errors.full_messages.each do |msg|
        compiledMsg += ( msg + '. ')
      end

      html= <<-HTML
    <div class="alert alert-danger">
    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
    #{compiledMsg}
    </div>
      HTML
      html.html_safe

    end

  end


  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = 'GBOL5'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end


  def search_dna_bank(id_string, individual = nil)
    individual = individual
    is_gbol_number = false
    message = ''
    service_url = ''

    if id_string.downcase.include? 'db'
      id_parts = id_string.match(/^([A-Za-z]+)[\s_]?([0-9]+)$/)
      if id_parts
        id_string = "#{id_parts[1]} #{id_parts[2]}" # ensure a space between 'DB' and the id number
      end

      message = "Query for DNABank ID '#{id_string}'...\n"
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{id_string}</like></filter><count>false</count></search></request>"
    elsif id_string.downcase.include? 'gbol'
      is_gbol_number = true

      message = "Query for GBoL number '#{id_string}'...\n"
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{id_string}</like></filter><count>false</count></search></request>"
    end

    puts message

    url = URI.parse(service_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }

    doc = Nokogiri::XML(res.body)

    specimen_unit_id = nil
    full_name = nil
    herbarium = nil
    collector = nil
    locality = nil
    longitude = nil
    latitude = nil

    begin
      unit = doc.at_xpath('//abcd21:Unit')

      if is_gbol_number
        unit_id = doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content # = DNA Bank number
      else
        unit_id = id_string
      end

      specimen_unit_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
      full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
      herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
      collector = unit.at_xpath('//abcd21:GatheringAgent').content
      locality = unit.at_xpath('//abcd21:LocalityText').content
      longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
      latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
      higher_taxon_rank = unit.at_xpath('//abcd21:HigherTaxonRank').content
      higher_taxon_name = unit.at_xpath('//abcd21:HigherTaxonName').content
    rescue
      puts 'Could not read ABCD.'
    end

    if is_gbol_number && unit_id
      puts "DNABank number: #{unit_id}"
    end

    if specimen_unit_id
      if individual.nil?
        individual = Individual.find_or_create_by(specimen_id: specimen_unit_id)
      end

      puts "ID: #{individual.id}"

      puts "Specimen ID: #{specimen_unit_id}"
      individual.update(:specimen_id => specimen_unit_id)

      if unit_id
        puts "DNABank number: #{unit_id}"
        individual.update(:DNA_bank_id => unit_id)
      end

      if collector
        puts "Collector: #{collector}"
        individual.update(:collector => collector.strip)
      end

      if locality
        puts "Locality: #{locality}"
        individual.update(:locality => locality)
      end

      if longitude
        puts "Longitude: #{longitude}"
        individual.update(:longitude => longitude)
      end

      if latitude
        puts "Latitude: #{latitude}"
        individual.update(:latitude => latitude)
      end

      if herbarium
        puts "Herbarium: #{herbarium}"
        individual.update(:herbarium => herbarium)
      end

      if full_name

        regex = /^(\w+)\s+(\w+)/
        matches = full_name.match(regex)

        if matches
          genus = matches[1]
          species_epithet = matches[2]
          species_component = "#{genus} #{species_epithet}"

          puts "Species: #{genus} #{species_epithet}"

          species = individual.species

          if species.nil?
            species = Species.find_or_create_by(:species_component => species_component)
            species.update(:genus_name => genus)
            species.update(:species_epithet => species_epithet)
            species.update(:composed_name => species.full_name)

            if higher_taxon_rank == 'familia'
              if higher_taxon_name.capitalize  == 'Labiatae'
                higher_taxon_name = 'Lamiaceae'
              end
              family = Family.find_or_create_by(:name => higher_taxon_name.capitalize)

              puts "Family: #{higher_taxon_name}"
              species.update(:family => family)
            end

            individual.update(:species => species)
          end
        end

      end

      isolate = Isolate.where(:lab_nr => id_string).first

      if isolate
        isolate.update(:individual => individual)
      end

    end

    puts 'Done.'
    return individual
  end
end
