# frozen_string_literal: true

class Isolate < ApplicationRecord
  extend Import
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  belongs_to :micronic_plate
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual

  validates_presence_of :lab_nr

  after_save :assign_specimen, if: :lab_nr_changed?

  scope :recent, -> { where('isolates.updated_at > ?', 1.hours.ago) }
  scope :no_controls, -> { where(negative_control: false) }

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    isolates = Isolate.select(:species_id).includes(:individual).joins(individual: { species: { family: { order: :higher_order_taxon } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    isolates_s = Isolate.select(:species_component).includes(:individual).joins(individual: { species: { family: { order: :higher_order_taxon } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    isolates_i = Isolate.select(:individual_id).joins(individual: { species: { family: { order: :higher_order_taxon } } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })

    [isolates.size, isolates_s.distinct.count, isolates.distinct.count, isolates_i.distinct.count]
  end

  def self.import(file, project_id)
    spreadsheet = Isolate.open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Update existing isolate or create new, case-insensitive!
      lab_nr = row['GBoL Isolation No.']
      lab_nr ||= row['DNA Bank No']

      next unless lab_nr # Cannot save isolate without lab_nr

      isolate = Isolate.where('lab_nr ILIKE ?', lab_nr).first
      isolate ||= Isolate.new(lab_nr: lab_nr)

      plant_plate = PlantPlate.find_or_create_by(name: row['GBoL5 Tissue Plate No.'].to_i.to_s)
      plant_plate.add_project(project_id)
      isolate.plant_plate = plant_plate

      isolate.well_pos_plant_plate = row['G5o Well']

      isolate.micronic_tube_id = row['Tube ID 2D (G5o Micronic)']

      isolate.tissue_id = 2 # Seems to be always "Leaf (Herbarium)", so no import needed

      isolate.negative_control = true if row['Tissue Type'] == 'control'

      isolate.add_project(project_id)

      isolate.save!

      individual = row['Voucher ID']

      next if individual.blank?

      individual = Individual.find_or_create_by(specimen_id: individual) # Assign to existing or new individual

      individual.collector = row['Collector']
      individual.herbarium = row['Herbarium']
      individual.country = row['Country']
      individual.state_province = row['State/Province']
      individual.locality = row['Locality']
      individual.latitude = row['Latitude']
      individual.longitude = row['Longitude']
      individual.latitude_original = row['Latitude (original)']
      individual.longitude_original = row['Longitude (original)']
      individual.elevation = row['Elevation']
      individual.exposition = row['Exposition']
      individual.habitat = row['Habitat']
      individual.substrate = row['Substrate']
      individual.life_form = row['Life form']
      individual.collection_nr = row['Collection number']
      individual.collection_date = row['Date']
      individual.determination = row['Determination']
      individual.revision = row['Revision']
      individual.confirmation = row['Confirmation']
      individual.comments = row['Comments']

      individual.add_project(project_id)

      individual.save!

      isolate.update(individual: individual)
    end
  end

  def assign_specimen
    search_dna_bank(lab_nr)
  end

  def individual_name
    individual.try(:specimen_id)
  end

  def individual_name=(name)
    if name == ''
      self.individual = nil
    else
      self.individual = Individual.find_or_create_by(specimen_id: name) if name.present? # TODO is it used? Add project if so
    end
  end

  private

  def search_dna_bank(id_string, individual = nil)
    individual ||= individual
    is_gbol_number = false
    message = ''
    service_url = ''

    if id_string.downcase.include? 'db'
      id_parts = id_string.match(/^([A-Za-z]+)[\s_]?([0-9]+)$/)
      dna_bank_id = id_parts ? "#{id_parts[1]} #{id_parts[2]}" : id_string # Ensure a space between 'DB' and the ID number

      message = "Query for DNABank ID '#{dna_bank_id}'...\n"
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{dna_bank_id}</like></filter><count>false</count></search></request>"
    elsif id_string.downcase.include? 'gbol'
      is_gbol_number = true

      message = "Query for GBoL number '#{id_string}'...\n"
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{id_string}</like></filter><count>false</count></search></request>"
    end

    puts message

    url = URI.parse(service_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
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
      unit_id = is_gbol_number ? doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content : id_string # UnitID field contains DNA bank number
      specimen_unit_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content
      full_name = unit.at_xpath('//abcd21:FullScientificNameString').content
      herbarium = unit.at_xpath('//abcd21:SourceInstitutionCode').content
      collector = unit.at_xpath('//abcd21:GatheringAgent').content
      locality = unit.at_xpath('//abcd21:LocalityText').content
      longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
      latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
      higher_taxon_rank = unit.at_xpath('//abcd21:HigherTaxonRank').content
      higher_taxon_name = unit.at_xpath('//abcd21:HigherTaxonName').content
    rescue StandardError
      puts 'Could not read ABCD.'
    end

    if specimen_unit_id
      individual ||= Individual.find_or_create_by(specimen_id: specimen_unit_id)
      individual.add_projects(projects.pluck(:id))

      individual.update(specimen_id: specimen_unit_id)
      individual.update(DNA_bank_id: unit_id) if unit_id
      individual.update(collector: collector.strip) if collector
      individual.update(locality: locality) if locality
      individual.update(longitude: longitude) if longitude
      individual.update(latitude: latitude) if latitude
      individual.update(herbarium: herbarium) if herbarium

      if full_name
        regex = /^(\w+)\s+(\w+)/
        matches = full_name.match(regex)

        if matches
          genus = matches[1]
          species_epithet = matches[2]
          species_component = "#{genus} #{species_epithet}"

          species = individual.species
          if species.nil?
            species = Species.find_or_create_by(species_component: species_component)
            species.add_projects(projects.pluck(:id))
            species.update(genus_name: genus, species_epithet: species_epithet, composed_name: species.full_name)

            if higher_taxon_rank == 'familia'
              higher_taxon_name = 'Lamiaceae' if higher_taxon_name.capitalize == 'Labiatae'

              family = Family.find_or_create_by(name: higher_taxon_name.capitalize)
              family.add_projects(projects.pluck(:id))
              species.update(family: family)
            end

            individual.update(species: species)
          end
        end
      end

      self.update_column(:individual_id, individual.id) # Does not trigger callbacks to avoid infinite loop

      puts 'Done.'
    end
  end
end
