class Isolate < ActiveRecord::Base
  has_many :marker_sequences
  has_many :contigs
  belongs_to :micronic_plate
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual


  scope :recent, ->  { where('isolates.updated_at > ?', 1.hours.ago)}

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)

    isolates=Isolate.select("species_id").includes(:individual).joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    isolates_i=Isolate.select("individual_id").joins(:individual => {:species => {:family => {:order => :higher_order_taxon}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})

    [isolates.count, isolates.uniq.count, isolates_i.uniq.count]
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


  def self.correct_coordinates(file)
    spreadsheet = Roo::Excelx.new(file, nil, :ignore)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|

      row = Hash[[header, spreadsheet.row(i)].transpose]


      #isolate = Isolate.find_by(:lab_nr => row['GBoL Isolation No.'])

      isolate = Isolate.find_by(:dna_bank_id => row['DNA Bank No'].gsub(' ', ''))


      unless isolate.nil?

        individual = isolate.individual

        unless individual.nil?
          individual.update(:latitude=>row['Latitude'])
          individual.update(:longitude=>row['Longitude'])
          individual.save!
        end

      end

    end
  end

  def self.import_dnabank_info(file)
    spreadsheet = Roo::Excelx.new(file, nil, :ignore)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|

      row = Hash[[header, spreadsheet.row(i)].transpose]

      # update existing isolate or create new
      isolate = Isolate.find_or_create_by(:lab_nr => row['GBoL Isolation No.'])

      if row['DNA Bank No']
        isolate.dna_bank_id=row['DNA Bank No'].gsub(' ', '')
      end

      isolate.save!

      # create new individual (specimen_id will be slurped in from DNA Bank later once available there):
      individual = Individual.create(:specimen_id => "<no info available in DNA Bank>")

      individual.save!

      isolate.update(:individual_id => individual.id)

      # assign individual to existing or new species:
      sp_name = ''

      unless row['Genus'].nil?
        gen_name = row['Genus']
        gen_name.strip!
        sp_name += gen_name
      end

      unless row['Species'].nil?
        sp_ep= row['Species']
        sp_ep.strip!
        sp_name += ' '
        sp_name += sp_ep
      end

      unless row['Subspecies'].nil?
        sub_sp = row['Subspecies']
        sub_sp.strip!
        sp_name += ' '
        sp_name += sub_sp

      end

      species = Species.find_or_create_by(:composed_name => sp_name)

      # if for whatever weird reason the species is not yet in db, also read & assign its family

      if species.genus_name.nil?

        species.update(:genus_name => gen_name, :species_epithet => sp_ep)

        unless row['Subspecies'].nil?
          species.update(:infraspecific => sub_sp)
        end

        unless row['Family'].nil?
          family_name= row['Family'].capitalize
          family = Family.find_or_create_by(:name => family_name)

          species.update(:family_id => family.id)
        end
      end

      species.save!

      individual.update(:species_id => species.id)
    end
  end


  def self.import(file)

    spreadsheet = Roo::Excelx.new(file, nil, :ignore)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      #only direct attributes; associations are extra:

      # update existing isolate or create new
      isolate = Isolate.find_or_create_by(:lab_nr => row['GBoL Isolation No.'])

      isolate.well_pos_plant_plate = row['G5o Well']
      isolate.micronic_tube_id=row['Tube ID 2D (G5o Micronic)']

      if row['DNA Bank No']
        isolate.dna_bank_id=row['DNA Bank No'].gsub(' ', '')
      end

      isolate.save!

      # assign to existing or new individual:
      individual = Individual.find_or_create_by(:specimen_id => row['Voucher ID'])

      individual.collector=row['Collector']
      individual.herbarium=row['Herbarium']
      individual.country=row['Country']
      individual.state_province=row['State/Province']
      individual.locality=row['Locality']
      individual.latitude=row['Latitude']
      individual.longitude=row['Longitude']
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

      # assign individual to existing or new species:
      sp_name = ''

      unless row['Genus'].nil?
        gen_name = row['Genus']
        gen_name.strip!
        sp_name += gen_name
      end

      unless row['Species'].nil?
        sp_ep= row['Species']
        sp_ep.strip!
        sp_name += ' '
        sp_name += sp_ep
      end

      unless row['Subspecies'].nil?
        sub_sp = row['Subspecies']
        sub_sp.strip!
        sp_name += ' '
        sp_name += sub_sp

      end

      species = Species.find_or_create_by(:composed_name => sp_name)

      # if for whatever weird reason the species is not yet in db, also read & assign its family

      if species.genus_name.nil?

        species.update(:genus_name => gen_name, :species_epithet => sp_ep)

        unless row['Subspecies'].nil?
          species.update(:infraspecific => sub_sp)
        end

        unless row['Family'].nil?
          family_name= row['Family'].capitalize
          family = Family.find_or_create_by(:name => family_name)

          species.update(:family_id => family.id)
        end
      end

      species.save!

      individual.update(:species_id => species.id)

    end
  end

  #  this code still needed ? has not been refactored to "isolate":

  # def isolate_name
  #   copy.try(:name)
  # end
  #
  # def isolate_name=(name)
  #   self.copy = Isolate.find_or_create_by(:name => name) if name.present?
  # end

end