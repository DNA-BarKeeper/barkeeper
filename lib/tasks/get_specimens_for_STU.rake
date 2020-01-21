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
    line << "gbol5.de/individuals/#{individual.id}/edit" # evtl. Bemerkungen zur Probe
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