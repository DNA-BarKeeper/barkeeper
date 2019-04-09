# frozen_string_literal: true

module Import
  extend ActiveSupport::Concern

  # Opens +file+ as a spreadsheet depending on its file ending
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    when '.ods' then Roo::OpenOffice.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def read_abcd(id, query_field = 'UnitID')
    query_id = id
    abcd_query_field = ''

    case query_field
    when'SpecimenUnit'
      abcd_query_field = 'SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'
    when 'UnitID'
      abcd_query_field = query_field
    end

    if id.downcase.include? 'db'
      id_parts = id.match(/^([A-Za-z]+)[\s_]?([0-9]+)$/)
      query_id = id_parts ? "#{id_parts[1]} #{id_parts[2]}" : id # Ensure a space between 'DB' and the ID number
    end

    service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/#{abcd_query_field}'>#{query_id}</like></filter><count>false</count></search></request>"

    url = URI.parse(service_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    doc = Nokogiri::XML(res.body)

    search_hits = doc.at_xpath('//biocase:content').attributes['totalSearchHits'].value.to_i

    results = {}

    if search_hits > 0
      unit = doc.at_xpath('//abcd21:Unit')
      results[:unit_id] = query_field == 'UnitID' ? id : doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content.strip
      results[:specimen_unit_id] = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content.strip
      results[:genus] = unit.at_xpath('//abcd21:GenusOrMonomial').content.strip
      results[:species_epithet] = unit.at_xpath('//abcd21:FirstEpithet').content.strip
      results[:infraspecific] = unit.at_xpath('//abcd21:InfraspecificEpithet').content.strip
      results[:herbarium] = unit.at_xpath('//abcd21:SourceInstitutionCode').content.strip
      results[:collector] = unit.at_xpath('//abcd21:GatheringAgent').content.strip
      results[:locality] = unit.at_xpath('//abcd21:LocalityText').content.strip
      results[:longitude] = unit.at_xpath('//abcd21:LongitudeDecimal').content.strip
      results[:latitude] = unit.at_xpath('//abcd21:LatitudeDecimal').content.strip
      results[:higher_taxon_rank] = unit.at_xpath('//abcd21:HigherTaxonRank').content.strip
      results[:higher_taxon_name] = unit.at_xpath('//abcd21:HigherTaxonName').content.strip
    else
      puts "No entries could be found for #{query_field} #{id}."
    end

    results
  end
end
