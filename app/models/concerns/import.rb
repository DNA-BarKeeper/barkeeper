#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

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

  def query_dna_bank(id, data_source = 'dna_bank')
    query_id = id

    if id.downcase.include? 'db'
      id_parts = id.match(/^([A-Za-z]+)[\s_]?([0-9]+)$/)
      query_id = id_parts ? "#{id_parts[1]} #{id_parts[2]}" : id # Ensure a space between 'DB' and the ID number
    end

    service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=#{data_source}&query=<?xml version='1.0' encoding='UTF-8'?>
<request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search>
<requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat>
<responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter>
<like path='/DataSets/DataSet/Units/Unit/UnitID'>#{query_id}</like></filter><count>false</count></search></request>"

    url = URI.parse(service_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    doc = Nokogiri::XML(res.body)

    search_hits = doc.at_xpath('//biocase:content').attributes['totalSearchHits'].value.to_i

    results = {}

    if search_hits > 0
      unit = doc.at_xpath('//abcd21:Unit')
      results[:unit_id] = doc.at_xpath('//abcd21:Unit/abcd21:UnitID')&.content&.strip
      results[:specimen_unit_id] = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID')&.content&.strip
      results[:genus] = unit.at_xpath('//abcd21:GenusOrMonomial')&.content&.strip
      results[:species_epithet] = unit.at_xpath('//abcd21:FirstEpithet')&.content&.strip
      results[:infraspecific] = unit.at_xpath('//abcd21:InfraspecificEpithet')&.content&.strip
      results[:collection] = unit.at_xpath('//abcd21:SourceInstitutionCode')&.content&.strip
      results[:collector] = unit.at_xpath('//abcd21:GatheringAgent')&.content&.strip
      results[:locality] = unit.at_xpath('//abcd21:LocalityText')&.content&.strip
      results[:longitude] = unit.at_xpath('//abcd21:LongitudeDecimal')&.content&.strip
      results[:latitude] = unit.at_xpath('//abcd21:LatitudeDecimal')&.content&.strip
      results[:higher_taxon_rank] = unit.at_xpath('//abcd21:HigherTaxonRank')&.content&.strip
      results[:higher_taxon_name] = unit.at_xpath('//abcd21:HigherTaxonName')&.content&.strip
    end

    results
  end
end
