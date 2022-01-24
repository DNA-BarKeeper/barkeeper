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

class Individual < ApplicationRecord
  include ProjectRecord
  include PgSearch::Model

  has_many :isolates
  belongs_to :taxon
  belongs_to :herbarium
  belongs_to :tissue

  has_many_attached :voucher_images
  validates :voucher_images, limit: { min: 0, max: 5 }

  after_save :assign_dna_bank_info, if: :identifier_has_changed?
  after_save :update_isolate_tissue, if: :saved_change_to_tissue_id?

  multisearchable against: [:DNA_bank_id, :collector, :collectors_field_number, :comments, :country, :habitat,
                            :locality, :specimen_id]

  scope :without_taxon, -> { where(taxon: nil) }
  scope :without_isolates, -> { left_outer_joins(:isolates).select(:id).group(:id).having('count(isolates.id) = 0') }
  scope :no_species_isolates, -> { without_taxon.left_outer_joins(:isolates).select(:id).group(:id).having('count(isolates.id) = 0') }
  scope :bad_longitude, -> { where(longitude: nil).where.not(longitude_original: [nil, ''])
                                 .where('individuals.longitude_original NOT SIMILAR TO ?', '[0-9]+\.*[0-9]*') }
  scope :bad_latitude, -> { where(latitude: nil).where.not(latitude_original: [nil, ''])
                                .where('individuals.latitude_original NOT SIMILAR TO ?', '[0-9]+\.*[0-9]+') }
  scope :bad_location, -> { bad_latitude.or(Individual.bad_longitude) }

  def self.to_csv(project_id)
    header = %w{ Database_ID specimen_id taxon_name determination herbarium collectors_field_number collector collection_date
state_province country latitude longitude elevation exposition locality habitat comments }

    attributes = %w{ id specimen_id taxon_name determination herbarium_code collectors_field_number collector collected
state_province country latitude longitude elevation exposition locality habitat comments }

    CSV.generate(headers: true) do |csv|
      csv << header.map { |entry| entry.humanize }

      in_project(project_id).includes(:taxon).each do |individual|
        csv << attributes.map{ |attr| individual.send(attr) }
      end
    end
  end

  def taxon_name
    self.try(:taxon)&.scientific_name
  end

  def taxon_name=(scientific_name)
    if name == ''
      self.taxon = nil
    else
      self.taxon = Taxon.find_by(scientific_name: scientific_name) if scientific_name.present?
    end
  end

  def identifier_has_changed?
    saved_change_to_specimen_id? || saved_change_to_DNA_bank_id?
  end

  def assign_dna_bank_info
    query_dna_bank(specimen_id) if specimen_id
  end

  def update_isolate_tissue
    isolates = self.isolates
    isolates.update_all(tissue_id: self.tissue_id)
  end

  private

  def query_dna_bank(specimen_id)
    # puts "Query for Specimen ID '#{specimen_id}'...\n"
    service_url = "http://ww3.bgbm.org/biocase/pywrapper.cgi?dsa=Herbar_BiNHum&query=<?xml version='1.0' encoding='UTF-8'?><request xmlns='http://www.biocase.org/schemas/protocol/1.3'><header><type>search</type></header><search><requestFormat>http://www.tdwg.org/schemas/abcd/2.1</requestFormat><responseFormat start='0' limit='200'>http://www.tdwg.org/schemas/abcd/2.1</responseFormat><filter><like path='/DataSets/DataSet/Units/Unit/UnitID'>#{specimen_id}</like></filter><count>false</count></search></request>"

    url = URI.parse(service_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    doc = Nokogiri::XML(res.body)

    begin
      unit = doc.at_xpath('//abcd21:Unit')

      unit_type = unit.at_xpath('//abcd21:KindOfUnit').content # Contains info if its a herbarium or tissue sample
      genus = unit.at_xpath('//abcd21:GenusOrMonomial').content
      species_epithet = unit.at_xpath('//abcd21:FirstEpithet').content
      infraspecific = unit.at_xpath('//abcd21:InfraspecificEpithet').content
      herbarium_name = unit.at_xpath('//abcd21:SourceInstitutionCode').content
      collector = unit.at_xpath('//abcd21:GatheringAgent').content
      locality = unit.at_xpath('//abcd21:LocalityText').content
      longitude = unit.at_xpath('//abcd21:LongitudeDecimal').content
      latitude = unit.at_xpath('//abcd21:LatitudeDecimal').content
      higher_taxon_rank = unit.at_xpath('//abcd21:HigherTaxonRank').content
      higher_taxon_name = unit.at_xpath('//abcd21:HigherTaxonName').content

      if unit_type == 'tissue'
        self.update(tissue: Tissue.find_by(name: 'Leaf (Silica)'))
      elsif unit_type == 'herbarium sheet'
        self.update(tissue: Tissue.find_by(name: 'Leaf (Herbarium)'))
      end

      self.update(collector: collector.strip) if collector
      self.update(locality: locality) if locality
      self.update(longitude: longitude) if longitude
      self.update(latitude: latitude) if latitude

      if herbarium_name
        herbarium = Herbarium.find_by(acronym: herbarium_name)
        self.update(herbarium: herbarium) if herbarium
      end

      if higher_taxon_rank == 'familia'
        assigned_family = Taxon.find_or_create_by_sci_name_or_synonym(higher_taxon_name.capitalize, {taxonomic_rank: :is_family}) # TODO: Who is the parent in case family does not exist yet?
        assigned_family.add_projects(projects.pluck(:id))
      end

      # Assign new individual to either genus, species or subspecies found or created by ABCD
      if genus
        parent_family = Taxon.find(assigned_family.id)
        assigned_genus = Taxon.find_or_create_by(taxonomic_rank: :is_genus,
                                                 scientific_name: genus,
                                                 parent: parent_family)
        assigned_genus.add_projects(projects.pluck(:id))

        if species_epithet
          parent_genus = Taxon.find(genus.id)
          assigned_species = Taxon.find_or_create_by(taxonomic_rank: :is_species,
                                                     scientific_name: genus + ' ' + species_epithet,
                                                     parent: parent_genus)
          assigned_species.add_projects(projects.pluck(:id))

          if infraspecific
            parent_species = Taxon.find(assigned_species.id)
            assigned_subspecies = Taxon.find_or_create_by(taxonomic_rank: :is_subspecies,
                                                          scientific_name: genus + ' ' + species_epithet + ' ' + infraspecific,
                                                          parent: parent_species)
            assigned_subspecies.add_projects(projects.pluck(:id))

            self.update(taxon: assigned_subspecies)
          else
            self.update(taxon: assigned_species)
          end
        else
          self.update(taxon: assigned_genus)
        end
      elsif assigned_family
        self.update(taxon: assigned_family)
      end
    rescue StandardError
      # puts 'Could not read ABCD.'
    else # No exceptions occurred
      # puts 'Successfully finished.'
    end
  end
end
