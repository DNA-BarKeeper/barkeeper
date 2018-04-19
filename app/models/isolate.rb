class Isolate < ApplicationRecord
  include CommonFunctions
  include ProjectModule

  has_many :marker_sequences
  has_many :contigs
  belongs_to :micronic_plate
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual
  has_and_belongs_to_many :projects, -> { distinct }

  validates_presence_of :lab_nr

  before_create :assign_specimen

  scope :recent, -> { where('isolates.updated_at > ?', 1.hours.ago) }
  scope :no_controls, -> { where(:negative_control => false) }

  def self.isolates_in_order(order_id)
    require 'csv'

    puts 'Writing CSV...'

    CSV.open('caryophyllales.csv', 'w') do |csv|
      markers = Marker.gbol_marker.order(:name)
      header = ['Web_App_ID',
                'GBoL-Nr',
                'Artname',
                'micronic_plate_id_copy',
                'well_pos_micronic_plate_copy',
                'micronic_tube_id_copy',
                'concentration_copy',
                'Location_in_Rack',
                'RackShelf',
                'Freezer']

      markers.each { |m| header << m.name }
      csv << header

      Isolate.includes(:individual).joins(:individual => {:species => {:family => :order}}).where(families: {order_id: order_id}).each do |i|
        if i.micronic_plate_id_copy

          micronic_plate_copy = MicronicPlate.includes(:lab_rack).find(i.micronic_plate_id_copy)
          marker_contig_counts_string = ''

          Marker.gbol_marker.order(:name).each do |m|
            marker_contig_counts_string += "#{i.contigs.assembled.where(:marker_id => m.id).count}\t"
          end

          csv << [
            i.id,
            i.lab_nr,
            i.individual.species.composed_name,
            micronic_plate_copy.micronic_plate_id,
            i.well_pos_micronic_plate_copy,
            i.micronic_tube_id_copy.to_i,
            i.concentration_copy,
            micronic_plate_copy.location_in_rack,
            micronic_plate_copy.try(:lab_rack).try(:rackcode),
            micronic_plate_copy.try(:lab_rack).try(:shelf),
            micronic_plate_copy.try(:lab_rack).try(:freezer).try(:freezercode),
            marker_contig_counts_string
          ]
        end
      end
    end

    puts 'Finished.'
  end

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    isolates = Isolate.select("species_id").includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_s = Isolate.select("species_component").includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_i = Isolate.select("individual_id").joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})

    [isolates.count, isolates_s.distinct.count, isolates.distinct.count, isolates_i.distinct.count]
  end

  # Variant for ggf. new specimen data + ggf new isolates
  def self.import(file)
    spreadsheet = CommonFunctions.open_spreadsheet(file)
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

      isolate.tissue_id = 2 # seems to be always "Leaf (Herbarium)", so no import needed

      isolate.negative_control = true if row['Tissue Type']=='control'

      isolate.save!

      # Assign to existing or new individual:
      individual = Individual.find_or_create_by( specimen_id: row['Voucher ID'] )

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

      individual.save!

      isolate.update(individual_id: individual.id)

      species = nil
      species_id = row['GBoL5_TaxID'].to_i
      begin
        species = Species.find(species_id)
      rescue
      end

      if species
        individual.update(species_id: species.id)
      else
        msg = "No matching spp found for #{species_id}"
        Issue.create(title: msg)
      end
    end
  end

  def assign_specimen
    self.individual_id = CommonFunctions.search_dna_bank(self.lab_nr)&.id # only assign individual id if dna bank search had a result
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