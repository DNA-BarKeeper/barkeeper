# frozen_string_literal: true

class Individual < ApplicationRecord
  include ProjectRecord
  include PgSearch

  has_many :isolates
  belongs_to :species
  belongs_to :herbarium
  belongs_to :tissue

  # after_save :assign_dna_bank_info, if: :specimen_id_changed?

  pg_search_scope :quick_search, against: %i[specimen_id herbarium collector collectors_field_number]

  scope :without_species, -> { where(species: nil) }
  scope :without_isolates, -> { left_outer_joins(:isolates).select(:id).group(:id).having('count(isolates.id) = 0') }
  scope :no_species_isolates, -> { without_species.left_outer_joins(:isolates).select(:id).group(:id).having('count(isolates.id) = 0') }
  scope :bad_longitude, -> { where('individuals.longitude_original NOT SIMILAR TO ?', '[0-9]{1,}\.{0,}[0-9]{0,}') }
  scope :bad_latitude, -> { where('individuals.latitude_original NOT SIMILAR TO ?', '[0-9]{1,}\.{0,}[0-9]{0,}') }
  scope :bad_location, -> { bad_latitude.or(Individual.bad_longitude) }

  def self.to_csv(options = {})
    # Change to_csv block to list attributes/values individually
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |individual|
        csv << individual.attributes.values_at(*column_names)
      end
    end
  end

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    individuals = Individual.select('species_id').joins(species: { family: { order: :higher_order_taxon } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    individuals_s = Individual.select('species_component').joins(species: { family: { order: :higher_order_taxon } }).where(orders: { higher_order_taxon_id: higher_order_taxon_id })
    [individuals.count, individuals_s.distinct.count, individuals.distinct.count]
  end

  def species_name
    species.try(:composed_name)
  end

  def species_name=(name)
    if name == ''
      self.species = nil
    else
      self.species = Species.find_or_create_by(composed_name: name) if name.present? # TODO is it used? Add project if so
    end
  end

  # def assign_dna_bank_info
  #   query_dna_bank(specimen_id) if specimen_id
  # end

  private

  # def query_dna_bank(specimen_id)
  #   puts "Query for Specimen ID '#{specimen_id}'...\n"
  #   service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=DNA_Bank&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{dna_bank_id}</like></filter><count>false</count></search></request>"
  #
  #   url = URI.parse(service_url)
  #   req = Net::HTTP::Get.new(url.to_s)
  #   res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
  #   doc = Nokogiri::XML(res.body)
  #
  #   genus = nil
  #   species_epithet = nil
  #   infraspecific = nil
  #   herbarium_name = nil
  #   collector = nil
  #   locality = nil
  #   longitude = nil
  #   latitude = nil
  #   higher_taxon_rank = nil
  #   higher_taxon_name = nil
  #
  #   begin
  #     unit = doc.at_xpath('//abcd21:Unit')
  #     unit_type = unit.at_xpath('//abcd21:UnitAssociation/abcd21:KindOfUnit').content # Contains info if its a herbarium or tissue sample
  #     genus = unit.at_xpath('//abcd21:GenusOrMonomial').content
  #     species_epithet = unit.at_xpath('//abcd21:FirstEpithet').content
  #     infraspecific = unit.at_xpath('//abcd21:InfraspecificEpithet').content
  #     herbarium_name = unit.at_xpath('//abcd21:SourceInstitutionCode').content
  #     collector = unit.at_xpath('//abcd21:GatheringAgent').content
  #     locality = unit.at_xpath('//abcd21:LocalityText').content
  #     longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
  #     latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
  #     higher_taxon_rank = unit.at_xpath('//abcd21:HigherTaxonRank').content
  #     higher_taxon_name = unit.at_xpath('//abcd21:HigherTaxonName').content
  #   rescue StandardError
  #     puts 'Could not read ABCD.'
  #   end
  #
  #   if unit
  #     if unit_type == 'tissue'
  #       self.tissue == Tissue.find_by_name('Leaf (Silica)')
  #     elsif unit_type == 'herbarium sheet'
  #       self.tissue == Tissue.find_by_name('Leaf (Herbarium)')
  #     end
  #
  #     self.update(collector: collector.strip) if collector
  #     self.update(locality: locality) if locality
  #     self.update(longitude: longitude) if longitude
  #     self.update(latitude: latitude) if latitude
  #
  #     if herbarium_name
  #       herbarium = Herbarium.find_by(acronym: herbarium_name)
  #       self.update(herbarium: herbarium) if herbarium
  #     end
  #
  #     if genus && species_epithet
  #       if infraspecific
  #         composed_name = "#{genus} #{infraspecific} #{species_epithet}"
  #       else
  #         composed_name = "#{genus} #{species_epithet}"
  #       end
  #
  #       species = Species.find_or_create_by(composed_name: composed_name)
  #       species.add_projects(projects.pluck(:id))
  #       species.update(genus_name: genus,
  #                      species_epithet: species_epithet,
  #                      infraspecific: infraspecific,
  #                      species_component: "#{genus} #{species_epithet}")
  #
  #       if higher_taxon_rank == 'familia'
  #         higher_taxon_name = 'Lamiaceae' if higher_taxon_name.capitalize == 'Labiatae'
  #
  #         family = Family.find_or_create_by(name: higher_taxon_name.capitalize)
  #         family.add_projects(projects.pluck(:id))
  #         species.update(family: family)
  #       end
  #
  #       self.update(species: species)
  #     end
  #
  #     puts 'Done.'
  #   end
  # end
end
