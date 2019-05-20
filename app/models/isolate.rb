# frozen_string_literal: true

class Isolate < ApplicationRecord
  extend Import
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  has_many :clusters
  has_many :ngs_results
  has_many :ngs_runs, through: :clusters
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

  def self.import_abcd(file, project_id)

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
    if dna_bank_id
      assign_specimen_info(Isolate.read_abcd(dna_bank_id))
    else
      assign_specimen_info(Isolate.read_abcd(lab_nr))
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

  def assign_specimen_info(abcd_results, individual = nil)
    individual ||= individual

    if abcd_results[:specimen_unit_id]
      individual ||= Individual.find_or_create_by(specimen_id: abcd_results[:specimen_unit_id])
      individual.add_projects(projects.pluck(:id))

      individual.update(specimen_id: abcd_results[:specimen_unit_id])
      individual.update(DNA_bank_id: abcd_results[:unit_id]) if abcd_results[:unit_id]
      individual.update(collector: abcd_results[:collector]) if abcd_results[:collector]
      individual.update(locality: abcd_results[:locality]) if abcd_results[:locality]
      individual.update(longitude: abcd_results[:longitude]) if abcd_results[:longitude]
      individual.update(latitude: abcd_results[:latitude]) if abcd_results[:latitude]
      individual.update(herbarium: abcd_results[:herbarium]) if abcd_results[:herbarium]

      if abcd_results[:genus] && abcd_results[:species_epithet]
        if abcd_results[:infraspecific]
          composed_name = "#{abcd_results[:genus]} #{abcd_results[:infraspecific]} #{abcd_results[:species_epithet]}"
        else
          composed_name = "#{abcd_results[:genus]} #{abcd_results[:species_epithet]}"
        end

        species = Species.find_or_create_by(composed_name: composed_name)
        species.add_projects(projects.pluck(:id))
        species.update(genus_name: abcd_results[:genus],
                       species_epithet: abcd_results[:species_epithet],
                       infraspecific: abcd_results[:infraspecific],
                       species_component: "#{abcd_results[:genus]} #{abcd_results[:species_epithet]}")

        if abcd_results[:higher_taxon_rank] == 'familia'
          abcd_results[:higher_taxon_name] = 'Lamiaceae' if abcd_results[:higher_taxon_name].capitalize == 'Labiatae'

          family = Family.find_or_create_by(name: abcd_results[:higher_taxon_name].capitalize)
          family.add_projects(projects.pluck(:id))
          species.update(family: family)
        end

        individual.update(species: species)
      end

      self.update_column(:individual_id, individual.id) # Does not trigger callbacks to avoid infinite loop

      puts 'Done.'
    end
  end
end
