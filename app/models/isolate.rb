# frozen_string_literal: true

class Isolate < ApplicationRecord
  extend Import
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  has_many :clusters
  has_many :ngs_results
  has_many :ngs_runs, through: :clusters
  has_many :aliquots
  belongs_to :micronic_plate # TODO remove after all values are transferred to aliquots
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual

  accepts_nested_attributes_for :aliquots, allow_destroy: true

  validates :display_name, presence: { message: "Either a DNA Bank Number or a lab isolation number must be provided!" }
  before_validation :assign_display_name

  after_save :assign_specimen

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
      lab_isolation_nr = row['GBoL Isolation No.']
      lab_isolation_nr ||= row['DNA Bank No'] # TODO: Not correct/necessary anymore, change!

      next unless lab_isolation_nr # Cannot save isolate without lab_isolation_nr

      isolate = Isolate.where('lab_isolation_nr ILIKE ?', lab_isolation_nr).first
      isolate ||= Isolate.new(lab_isolation_nr: lab_isolation_nr)

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
      individual.collectors_field_number = row['Collection number']
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

  def assign_display_name(db_id = self.dna_bank_id, isolation_nr = self.lab_isolation_nr)
    if db_id && !db_id.empty?
      self.display_name = db_id
    else
      self.display_name = isolation_nr
    end
  end

  def assign_specimen
    if lab_isolation_nr_changed? || dna_bank_id_changed?
      if dna_bank_id
        search_dna_bank(dna_bank_id)
      else
        search_dna_bank(lab_isolation_nr)
      end
    end
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
    is_gbol_number = false

    if id_string.downcase.include? 'db'
      id_parts = id_string.match(/^([A-Za-z]+)[\s_]?([0-9]+)$/)
      dna_bank_id = id_parts ? "#{id_parts[1]} #{id_parts[2]}" : id_string # Ensure a space between 'DB' and the ID number

      message = "Query for DNABank ID '#{dna_bank_id}'...\n"
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{dna_bank_id}</like></filter><count>false</count></search></request>"
    elsif id_string.downcase.include? 'gbol'
      is_gbol_number = true

      message = "Query for GBoL number '#{id_string}'...\n"
      service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/SpecimenUnit/Preparations/preparation/sampleDesignations/sampleDesignation'>#{id_string}</like></filter><count>false</count></search></request>"
    else
      puts "The ID \"#{id_string}\" you provided is not valid."
      return
    end

    puts message

    url = URI.parse(service_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    doc = Nokogiri::XML(res.body)

    begin
      unit = doc.at_xpath('//abcd21:Unit')
      unit_id = is_gbol_number ? doc.at_xpath('//abcd21:Unit/abcd21:UnitID').content : id_string # UnitID field contains DNA bank number
      specimen_unit_id = unit.at_xpath('//abcd21:UnitAssociation/abcd21:UnitID').content

      if specimen_unit_id
        individual ||= self.individual
        individual ||= Individual.find_or_create_by(specimen_id: specimen_unit_id)
        individual.add_projects(projects.pluck(:id))

        individual.update(DNA_bank_id: unit_id) if unit_id

        # Specimen info will be retrieved from DNA bank if specimen ID has changed (or individual was newly created)

        self.update_column(:individual_id, individual.id) # Does not trigger callbacks to avoid infinite loop
      end
    rescue StandardError
      puts 'Could not read ABCD.'
    else # No exceptions occurred
      puts 'Successfully finished.'
    end
  end
end
