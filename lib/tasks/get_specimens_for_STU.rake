#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
namespace :data do
  @states = %w[Baden-Württemberg Bayern Berlin Brandenburg Bremen Hamburg
               Hessen Mecklenburg-Vorpommern Niedersachsen Nordrhein-Westfalen
               Rheinland-Pfalz Saarland Sachsen Sachsen-Anhalt Schleswig-Holstein
               Thüringen]

  @csv_header = ['Web App ID', 'Institut', 'Specimen ID (Sammlungsnummer)', 'Feldnummer',
                 'Familie', 'Taxon-Name', 'Erstbeschreiber Jahr',
                 'Name', 'Gewebetyp und Menge', 'Fixierungsmethode',
                 'evtl. Bemerkungen zur Probe', 'Fundortbeschreibung',
                 'Bundesland', 'Land', 'Datum', 'Breitengrad',
                 'Längengrad', 'Höhe/Tiefe [m]', 'Habitat', 'Sammler',
                 'Feld-Sammelnummer']

  task get_specimens_for_STU: :environment do
    csv = CSV.open('specimen_STU.csv', 'w+')
    csv << @csv_header

    # Individuals in current project from Stuttgart
    Individual.includes(species: :family).in_project(5).where(herbarium_code: 'STU').find_each do |individual|
      csv << create_csv_line(individual)
    end
  end

  task convert_specimen_ids: :environment do
    individuals = Individual.includes(species: :family).in_project(5).where(herbarium_code: 'STU')
    id_pattern = /^\d{2,6}$/
    prefix = 'SMNS-B-BR-'
    filler_char = '0'

    csv = CSV.open('specimen_STU_incorrect_id.csv', 'w+')
    csv << @csv_header

    cnt = 0

    individuals.each do |ind|
      if ind.specimen_id.match(id_pattern)
        id_length = ind.specimen_id.length
        ind.update(specimen_id: prefix + filler_char*(6-id_length) + ind.specimen_id)
        cnt += 1
      else
        csv << create_csv_line(ind)
      end
    end

    puts "Finished. #{cnt} IDs were updated to the new standard. Remaining cases were written to specimen_STU_incorrect_id.csv"

    csv.close
  end

  task get_specimen_with_incorrect_ids: :environment do
    individuals = Individual.joins(species: [family: [order: :higher_order_taxon]])
        .in_project(5)
        .where.not(herbarium_code: 'STU')
        .where.not(species: { family: { order: { higher_order_taxa: { name: ["Coniferopsida", "Magnoliopsida"]}}}})

    csv = CSV.open('specimen_incorrect_ids.csv', 'w+')
    csv << @csv_header

    stu_pattern = /SMNS-B-BR-\d{6}/
    tissue_pattern = /B\sGT\s\d{7}/
    herbar_pattern = /B\s10\s\d{7}/

    individuals.each do |ind|
      unless ind.specimen_id.match(stu_pattern) || ind.specimen_id.match(tissue_pattern) || ind.specimen_id.match(herbar_pattern)
        csv << create_csv_line(ind)
      end
    end

    csv.close
  end

  def create_csv_line(individual)
    include ActionView::Helpers::NumberHelper

    line = []

    line << individual.id # Internal ID

    line << individual.herbarium_code # Institute

    # Specimen ID (Sammlungsnummer)
    if individual.specimen_id
      line << individual.specimen_id
    else
      line << ''
    end

    # Feldnummer
    if individual.collectors_field_number&.include?('s.n.') || individual.collectors_field_number&.include?('s. n.')
      line << ''
    else
      line << individual.collectors_field_number
    end

    line << individual.try(:species).try(:family).try(:name) # Familie
    line << individual.try(:species).try(:name_for_display) # Taxonname
    line << individual.try(:species).try(:author) # Erstbeschreiber Jahr
    line << individual.determination # Name
    line << 'Blattmaterial' # Gewebetyp und Menge
    line << 'Silica gel' # Fixierungsmethode
    line << "#{ENV['PROJECT_DOMAIN']}/individuals/#{individual.id}/edit" # evtl. Bemerkungen zur Probe
    line << individual.locality # Fundortbeschreibung

    # Bundesland
    if individual.country == 'Germany' || individual.country == 'Deutschland'
      # Tests first if is a Bundesland; outputs nothing if other crap was entered in this field:
      if @states.include? individual.state_province
        line << individual.state_province
      else
        line << ''
      end
    else
      line << 'Europa' # Stuff from Schweiz etc.
    end

    line << individual.country # Land
    line << individual.collection_date # Datum
    line << number_with_precision(individual.latitude, precision: 5) # Breitengrad
    line << number_with_precision(individual.longitude, precision: 5) # Längengrad
    line <<  individual.elevation # Höhe/Tiefe [m]
    line << individual.habitat # Habitat
    line << individual.collector # Sammler
    line << individual.collectors_field_number # Feld-Sammelnummer
  end
end