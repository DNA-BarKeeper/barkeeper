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
  extend Import
  include ProjectRecord
  include PgSearch::Model

  has_many :isolates
  belongs_to :taxon
  belongs_to :collection
  belongs_to :tissue

  has_many_attached :voucher_images
  validates :voucher_images, limit: { min: 0, max: 5 }

  validates_presence_of :specimen_id, message: "ID can't be blank"

  after_save :import_abcd, if: :identifier_has_changed?
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
    header = %w{ Database_ID specimen_id taxon_name determination collection collectors_field_number collector collection_date
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

  def import_abcd
    identifier = specimen_id
    identifier ||= DNA_bank_id

    if identifier
      abcd_results = Individual.query_dna_bank(identifier, 'Herbar_BinHum')
      read_abcd_results(abcd_results)
    end
  end

  def update_isolate_tissue
    isolates = self.isolates
    isolates.update_all(tissue_id: self.tissue_id)
  end

  def read_abcd_results(abcd_results)
    self.collector = abcd_results[:collector] if abcd_results[:collector]
    self.locality = abcd_results[:locality] if abcd_results[:locality]

    coordinates = Geo::Coord.parse("#{abcd_results[:latitude]}, #{abcd_results[:longitude]}")
    if coordinates
      self.latitude = coordinates.latitude if coordinates.latitude
      self.longitude = coordinates.longitude if coordinates.longitude
    end
    self.latitude_original = abcd_results[:latitude] if abcd_results[:latitude]
    self.longitude_original = abcd_results[:longitude] if abcd_results[:longitude]

    if abcd_results[:collection]
      collection = Collection.find_or_create_by(acronym: abcd_results[:collection])
      self.collection = collection
    end

    if abcd_results[:higher_taxon_name] && abcd_results[:higher_taxon_rank]
      abcd_results[:higher_taxon_name] = 'Lamiaceae' if abcd_results[:higher_taxon_name].capitalize == 'Labiatae'

      taxon = Taxon.find_or_create_by(scientific_name: abcd_results[:higher_taxon_name].capitalize)
      taxon.add_projects(projects.pluck(:id))

      case abcd_results[:higher_taxon_rank]
      when 'phylum'
        taxonomic_rank = :is_division
      when 'classis'
        taxonomic_rank = :is_class
      when 'ordo'
        taxonomic_rank = :is_order
      when 'familia'
        taxonomic_rank = :is_family
      else
        taxonomic_rank = nil
      end
      taxon.update(taxonomic_rank: taxonomic_rank)
    end

    if abcd_results[:genus]
      parent = taxon

      taxon = Taxon.find_or_create_by(scientific_name: abcd_results[:genus], taxonomic_rank: :is_genus)
      taxon.add_projects(projects.pluck(:id))
      taxon.update(parent: parent)

      if abcd_results[:species_epithet]
        parent = taxon
        composed_name = "#{abcd_results[:genus]} #{abcd_results[:species_epithet]}"

        taxon = Taxon.find_or_create_by(scientific_name: composed_name, taxonomic_rank: :is_species)
        taxon.add_projects(projects.pluck(:id))
        taxon.update(parent: parent)

        if abcd_results[:infraspecific]
          parent = taxon
          composed_name = "#{abcd_results[:genus]} #{abcd_results[:infraspecific]} #{abcd_results[:species_epithet]}"

          taxon = Taxon.find_or_create_by(scientific_name: composed_name, taxonomic_rank: :is_subspecies)
          taxon.add_projects(projects.pluck(:id))
          taxon.update(parent: parent)
        end
      end
    end

    update(taxon: taxon)
    save!
  end
end
