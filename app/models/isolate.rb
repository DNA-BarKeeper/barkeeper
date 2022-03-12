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

class Isolate < ApplicationRecord
  extend Import
  include PgSearch::Model
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  has_many :clusters
  has_many :ngs_results
  has_many :ngs_runs, through: :clusters
  has_many :aliquots
  belongs_to :plant_plate
  belongs_to :tissue
  belongs_to :individual

  accepts_nested_attributes_for :aliquots, allow_destroy: true

  validates :display_name, presence: { message: "Either a DNA Bank Number or a lab isolation number must be provided!" }
  before_validation :assign_display_name

  after_save :assign_specimen

  multisearchable against: [:display_name, :dna_bank_id, :lab_isolation_nr]

  scope :recent, -> { where('isolates.updated_at > ?', 1.hours.ago) }
  scope :no_controls, -> { where(negative_control: false) }

  def self.import(file, project_id)
    spreadsheet = Isolate.open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Update existing isolate or create new, case-insensitive!
      lab_isolation_nr = row['Isolation No.']
      lab_isolation_nr ||= row['DNA Bank No.']

      next unless lab_isolation_nr # Cannot save isolate without lab_isolation_nr

      isolate = Isolate.where('lab_isolation_nr ILIKE ?', lab_isolation_nr).first
      isolate ||= Isolate.new(lab_isolation_nr: lab_isolation_nr)

      isolate.dna_bank_id = row['DNA Bank No.'] if row['DNA Bank No.']

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
      begin
        individual.collected = Date.parse(row['Date']) if row['Date']
      end
      individual.determination = row['Determination']
      individual.revision = row['Revision']
      individual.confirmation = row['Confirmation']
      individual.comments = row['Comments']

      if row['Genus'] && row['Species']
        if row['Subspecies']
          taxon = Taxon.find_or_create_by(scientific_name: [row['Genus'], row['Species'], row['Subspecies']].join(' '))
        else
          taxon = Taxon.find_or_create_by(scientific_name: [row['Genus'], row['Species']].join(' '))
        end
      end

      individual.taxon = taxon if taxon

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
    if saved_change_to_lab_isolation_nr? || saved_change_to_dna_bank_id?
      if dna_bank_id
        assign_specimen_info(Isolate.query_dna_bank(dna_bank_id))
      else
        assign_specimen_info(Isolate.query_dna_bank(lab_isolation_nr))
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

      if abcd_results[:herbarium]
        herbarium = Herbarium.find_or_create_by(acronym: abcd_results[:herbarium])
        individual.update(herbarium: herbarium)
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

      individual.update(taxon: taxon)

      self.update_column(:individual_id, individual.id) # Does not trigger callbacks to avoid infinite loop
    end
  end
end
