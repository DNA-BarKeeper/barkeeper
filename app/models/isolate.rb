class Isolate < ApplicationRecord
  include Import
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  belongs_to :micronic_plate
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual

  validates_presence_of :lab_nr

  before_create :assign_specimen

  scope :recent, -> { where('isolates.updated_at > ?', 1.hours.ago) }
  scope :no_controls, -> { where(:negative_control => false) }

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    isolates = Isolate.select(:species_id).includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_s = Isolate.select(:species_component).includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_i = Isolate.select(:individual_id).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})

    [isolates.size, isolates_s.distinct.count, isolates.distinct.count, isolates_i.distinct.count]
  end

  def self.import(file, project_id)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Update existing isolate or create new, case-insensitive!
      isolate = Isolate.where("lab_nr ILIKE ?", row['GBoL Isolation No.']).first
      isolate ||= Isolate.new(:lab_nr => row['GBoL Isolation No.'])

      plant_plate = PlantPlate.find_or_create_by(:name => row['GBoL5 Tissue Plate No.'].to_i.to_s)
      isolate.plant_plate = plant_plate

      isolate.well_pos_plant_plate = row['G5o Well']

      isolate.micronic_tube_id = row['Tube ID 2D (G5o Micronic)']

      isolate.tissue_id = 2 # Seems to be always "Leaf (Herbarium)", so no import needed

      isolate.negative_control = true if row['Tissue Type'] == 'control'

      isolate.add_project(project_id)

      isolate.save!

      # Assign to existing or new individual:
      individual = Individual.find_or_create_by(specimen_id: row['Voucher ID'])

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

      isolate.update(individual_id: individual.id)

      species_id = row['GBoL5_TaxID'].to_i
      begin
        species = Species.find(species_id)
        species.add_project_and_save(project_id)
        individual.update(species_id: species.id)
      rescue ActiveRecord::RecordNotFound
        issue = Issue.new(title: "No matching spp found for #{species_id}")
        issue.add_project_and_save(project_id)
      end
    end
  end

  def assign_specimen
    self.individual_id = search_dna_bank(lab_nr)&.id # Only assign individual_id if DNA bank search had a result
  end

  def individual_name
    individual.try(:specimen_id)
  end

  def individual_name=(name)
    if name == ''
      self.individual = nil
    else
      self.individual = Individual.find_or_create_by(:specimen_id => name) if name.present?
    end
  end
end