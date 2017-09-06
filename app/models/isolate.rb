class Isolate < ActiveRecord::Base
  include ApplicationHelper

  has_many :marker_sequences
  has_many :contigs
  belongs_to :micronic_plate
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual
  has_and_belongs_to_many :projects
  validates_presence_of :lab_nr

  before_create :assign_specimen

  scope :recent, ->  { where('isolates.updated_at > ?', 1.hours.ago)}
  scope :no_controls, -> { where(:negative_control => false)}

  def assign_specimen
    # suche in DNABank nach isolate id (lab_nr), extrahiere info über specimen ID aus ABCD records
    ind = search_dna_bank(self.lab_nr) # look for specimen in WebApp DB or create new one
    # self.update(:individual => ind) #seems to cause an endless loop
  end

  def self.isolates_in_order(order_id)

    markers=Marker.gbol_marker.order(:name).map { |m| m.name + "\t" }.join

    puts "Web app ID\tGBOL-Nr\tArtname\tmicronic plate id copy\twell pos micronic plate copy\tmicronic_tube_id_copy\tconcentration copy\tLocation in Rack\tRack\tShelf\tFreezer\t#{markers}"

    Isolate.includes(:individual).joins(:individual => {:species => {:family => :order}}).where(families: {order_id: order_id}).each do |i|

      if i.micronic_plate_id_copy

        micronic_plate_copy = MicronicPlate.includes(:lab_rack).find(i.micronic_plate_id_copy)

        marker_contig_counts_string = ""

        Marker.gbol_marker.order(:name).each do |m|
          marker_contig_counts_string += "#{i.contigs.assembled.where(:marker_id => m.id).count}\t"
        end


        puts "#{i.id}\t#{i.lab_nr}\t#{i.individual.species.composed_name}\t#{micronic_plate_copy.micronic_plate_id}\t#{i.well_pos_micronic_plate_copy}\t#{i.micronic_tube_id_copy.to_i}\t#{i.concentration_copy}\t#{micronic_plate_copy.location_in_rack}\t#{micronic_plate_copy.try(:lab_rack).try(:rackcode)}\t#{micronic_plate_copy.try(:lab_rack).try(:shelf)}\t#{micronic_plate_copy.try(:lab_rack).try(:freezer).try(:freezercode)}\t#{marker_contig_counts_string}"
      end

    end

  end

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)

    isolates=Isolate.select("species_id").includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_s=Isolate.select("species_component").includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_i=Isolate.select("individual_id").joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})

    [isolates.count, isolates_s.uniq.count, isolates.uniq.count, isolates_i.uniq.count]
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

  # def self.correct_coordinates(file)
  #   spreadsheet = Roo::Excelx.new(file, nil, :ignore)
  #
  #   header = spreadsheet.row(1)
  #   (2..spreadsheet.last_row).each do |i|
  #
  #     row = Hash[[header, spreadsheet.row(i)].transpose]
  #
  #     #isolate = Isolate.find_by(:lab_nr => row['GBoL Isolation No.'])
  #
  #     isolate = Isolate.find_by(:dna_bank_id => row['DNA Bank No'].gsub(' ', ''))
  #
  #
  #     unless isolate.nil?
  #
  #       individual = isolate.individual
  #
  #       unless individual.nil?
  #         individual.update(:latitude=>row['Latitude'])
  #         individual.update(:longitude=>row['Longitude'])
  #         individual.save!
  #       end
  #
  #     end
  #
  #   end
  # end


  # def self.import_dnabank_info(file)
  #   spreadsheet = Roo::Excelx.new(file, nil, :ignore)
  #
  #   header = spreadsheet.row(1)
  #   (2..spreadsheet.last_row).each do |i|
  #
  #     row = Hash[[header, spreadsheet.row(i)].transpose]
  #
  #     # update existing isolate or create new
  #     isolate = Isolate.find_or_create_by(:lab_nr => row['GBoL Isolation No.'])
  #
  #     if row['DNA Bank No']
  #       isolate.dna_bank_id=row['DNA Bank No'].gsub(' ', '')
  #     end
  #
  #     isolate.save!
  #
  #     # create new individual (specimen_id will be slurped in from DNA Bank later once available there):
  #     individual = Individual.create(:specimen_id => "<no info available in DNA Bank>")
  #
  #     individual.save!
  #
  #     isolate.update(:individual_id => individual.id)
  #
  #     # assign individual to existing or new species:
  #     sp_name = ''
  #
  #     unless row['Genus'].nil?
  #       gen_name = row['Genus']
  #       gen_name.strip!
  #       sp_name += gen_name
  #     end
  #
  #     unless row['Species'].nil?
  #       sp_ep= row['Species']
  #       sp_ep.strip!
  #       sp_name += ' '
  #       sp_name += sp_ep
  #     end
  #
  #     unless row['Subspecies'].nil?
  #       sub_sp = row['Subspecies']
  #       sub_sp.strip!
  #       sp_name += ' '
  #       sp_name += sub_sp
  #
  #     end
  #
  #     species = Species.find_or_create_by(:composed_name => sp_name)
  #
  #     # if for whatever weird reason the species is not yet in db, also read & assign its family
  #
  #     if species.genus_name.nil?
  #
  #       species.update(:genus_name => gen_name, :species_epithet => sp_ep)
  #
  #       unless row['Subspecies'].nil?
  #         species.update(:infraspecific => sub_sp)
  #       end
  #
  #       unless row['Family'].nil?
  #         family_name= row['Family'].capitalize
  #         family = Family.find_or_create_by(:name => family_name)
  #
  #         species.update(:family_id => family.id)
  #       end
  #     end
  #
  #     species.save!
  #
  #     individual.update(:species_id => species.id)
  #   end
  # end


  # variant for ggf. new specimen data + ggf new isolates
  def self.import(file)

    spreadsheet = Roo::Excelx.new(file, nil, :ignore)

    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|

      row = Hash[[header, spreadsheet.row(i)].transpose]

      # update existing isolate or create new, case-insensitiv!

      isolate=Isolate.where("lab_nr ILIKE ?", row['GBoL Isolation No.']).first
      unless isolate
        isolate= Isolate.new(:lab_nr => row['GBoL Isolation No.'])
      end

      plant_plate = PlantPlate.find_or_create_by(:name => row['GBoL5 Tissue Plate No.'].to_i.to_s)

      isolate.plant_plate = plant_plate

      isolate.well_pos_plant_plate = row['G5o Well']
      isolate.micronic_tube_id=row['Tube ID 2D (G5o Micronic)']

      # deactivated - relevant for Berlin only:
      # if row['DNA Bank No']
      #   isolate.dna_bank_id=row['DNA Bank No'].gsub(' ', '')
      # end

      isolate.tissue_id = 2 # seems to be always "Leaf (Herbarium)", so no import needed

      if row['Tissue Type']=='control'
        isolate.negative_control=true
      end

      isolate.save!

      # assign to existing or new individual:

      specimen_id=row['Voucher ID']
      # individual = Individual.find_or_create_by(:specimen_id => specimen_id.to_i.to_s)
      individual = Individual.find_or_create_by(:specimen_id => specimen_id)

      individual.collector=row['Collector']
      individual.herbarium=row['Herbarium']
      individual.country=row['Country']
      individual.state_province=row['State/Province']
      individual.locality=row['Locality']
      # individual.latitude=row['Latitude']
      # individual.longitude=row['Longitude']
      # individual.latitude_original=row['Latitude (original)']
      # individual.longitude_original=row['Longitude (original)']
      individual.elevation=row['Elevation']
      individual.exposition=row['Exposition']
      individual.habitat=row['Habitat']
      individual.substrate=row['Substrate']
      individual.life_form=row['Life form']
      individual.collection_nr=row['Collection number']
      individual.collection_date=row['Date']
      individual.determination=row['Determination']
      individual.revision=row['Revision']
      individual.confirmation=row['Confirmation']
      individual.comments=row['Comments']

      individual.save!

      isolate.update(:individual_id => individual.id)

      # # assign individual to existing or new species:
      #
      # gen_name=""
      # sp_ep=""
      # sub_sp=""
      #
      # unless row['Genus'].nil?
      #   gen_name = row['Genus']
      #   gen_name.strip!
      # end
      #
      # unless row['Species'].nil?
      #   sp_ep= row['Species']
      #   sp_ep.strip!
      # end
      #
      # if row['Subspecies'].nil? and row['Variety'].nil?
      #   species=Species.where("genus_name ILIKE ?", gen_name).where("species_epithet ILIKE ?", sp_ep).where(:infraspecific => nil).first
      # else
      #
      #   unless row['Subspecies'].nil?
      #     sub_sp = row['Subspecies']
      #     sub_sp.strip!
      #   end
      #
      #   unless row['Variety'].nil?
      #     sub_sp = row['Variety']
      #     sub_sp.strip!
      #   end
      #
      #   species=Species.where("genus_name ILIKE ?", gen_name).where("species_epithet ILIKE ?", sp_ep).where("infraspecific ILIKE ?", sub_sp).first
      #
      # end

      species=nil
      species_id=row['GBoL5_TaxID'].to_i
      begin
        species = Species.find(species_id)
      rescue
      end

      if species
        individual.update(:species_id => species.id)
      else
        msg="No matching spp found for #{species_id}"
        Issue.create(:title => msg)
      end

    end
  end

# variant for correction lat/long:
#   def self.import(file)
#
#     spreadsheet = Roo::Excelx.new(file, nil, :ignore)
#
#     header = spreadsheet.row(1)
#
#     (2..spreadsheet.last_row).each do |i|
#
#       row = Hash[[header, spreadsheet.row(i)].transpose]
#
#       # update existing isolate or create new, case-insensitiv!
#
#       begin
#         specimen_id = row['Voucher ID'].to_i
#         individual = Individual.find_by(:specimen_id => specimen_id)
#         if individual
#           individual.latitude = row['Latitude (corrected)']
#           individual.longitude = row['Longitude (corrected)']
#           individual.latitude_original = row['Latitude (corrected)']
#           individual.longitude_original = row['Longitude (corrected)']
#           individual.save!
#           puts "#{i}: individual #{specimen_id} updated."
#         else
#           puts "#{i}: individual #{specimen_id} could not be changed."
#         end
#       rescue
#         puts "#{i}: individual #{specimen_id} not found"
#       end
#
#     end
#   end

# variant for DNA isolate data - eg Voucherlist_GBoL5_upload_v2.xlsx
#   def self.import(file)
#
#     spreadsheet = Roo::Excelx.new(file, nil, :ignore)
#
#     header = spreadsheet.row(1)
#
#     (2..spreadsheet.last_row).each do |i|
#
#       row = Hash[[header, spreadsheet.row(i)].transpose]
#
#       # update existing isolate or create new, case-insensitiv!
#
#       isolate=Isolate.where("lab_nr ILIKE ?", row['Nr.']).first
#
#       unless isolate
#         isolate= Isolate.new(:lab_nr => row['Nr.'])
#       end
#
#       isolate.micronic_tube_id_orig=row['G5o DNA Tube ID']
#       isolate.micronic_tube_id_copy=row['G5c DNA Tube ID']
#       isolate.well_pos_micronic_plate_orig=row['G5o Well Position']
#       isolate.well_pos_micronic_plate_copy=row['G5c Well Position']
#
#       # plate for original
#       micronic_plate_orig=MicronicPlate.find_or_create_by(:micronic_plate_id => row['G5o DNA Plate ID'])
#
#       # plate for copy
#       micronic_plate_copy=MicronicPlate.find_or_create_by(:micronic_plate_id => row['G5c DNA Plate ID'])
#
#       unless row['Rack'].nil? or row['Rack'].blank?
#         lab_rack=LabRack.find_or_create_by(:rackcode => row['Rack'])
#         lab_rack.shelf=row['Shelf']
#         freezer=Freezer.find_or_create_by(:freezercode => row['Freezer'])
#         lab_rack.freezer=freezer
#         lab_rack.save!
#         micronic_plate_orig.lab_rack = lab_rack
#         micronic_plate_copy.lab_rack = lab_rack
#       end
#
#       micronic_plate_orig.location_in_rack=row['Rack Position']
#       micronic_plate_copy.location_in_rack=row['Rack Position']
#
#       micronic_plate_orig.save!
#       micronic_plate_copy.save!
#
#       isolate.micronic_plate_id_orig=micronic_plate_orig.id
#       isolate.micronic_plate_id_copy=micronic_plate_copy.id
#
#       isolate.concentration_orig=row['DNA ng/μl']
#       isolate.concentration_copy=row['DNA ng/μl']
#
#       isolators=row['Bearbeiter']
#
#       if isolators
#         isolators=isolators.split(';')
#         isolator=isolators.first[2..-1]
#         user=User.where('name ILIKE ?', "%#{isolator}%").first
#         if user
#           isolate.user_id = user.id
#         end
#       end
#
#       isolate.isolation_date=row['Isolation date']
#
#       isolate.lab_id_copy=2 #BGMG
#       isolate.lab_id_orig=1 #NEES
#
#       isolate.save!
#
#     end
#   end

#variant for correcting plant plate (were in wrong col):
# def self.import(file)
#
#   spreadsheet = Roo::Excelx.new(file, nil, :ignore)
#
#   header = spreadsheet.row(1)
#
#   (2..spreadsheet.last_row).each do |i|
#
#     row = Hash[[header, spreadsheet.row(i)].transpose]
#
#     # update existing isolate or create new, case-insensitiv!
#
#     begin
#       isolate=Isolate.where("lab_nr ILIKE ?", row['Nr.']).first
#
#       plant_plate = PlantPlate.find_or_create_by(:name => row['GBoL5 Tissue Plate No.'].to_i.to_s)
#
#       isolate.plant_plate = plant_plate
#
#       isolate.tissue_id = 2
#
#       isolate.save!
#     rescue
#     end
#
#   end
# end

end