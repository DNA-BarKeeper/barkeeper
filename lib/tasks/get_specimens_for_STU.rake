namespace :data do
  task get_specimens_for_STU: :environment do
    include ActionView::Helpers::NumberHelper

    header_cells = ['Feldnummer', 'Institut', 'Sammlungs-Nr.',
                     'Familie', 'Taxon-Name', 'Erstbeschreiber Jahr',
                     'Name', 'Gewebetyp und Menge', 'Fixierungsmethode',
                     'evtl. Bemerkungen zur Probe', 'Fundortbeschreibung',
                     'Bundesland', 'Land', 'Datum', 'Breitengrad',
                     'Längengrad', 'Höhe/Tiefe [m]', 'Habitat', 'Sammler', 'Feld-Sammelnummer']

    states = %w[Baden-Württemberg Bayern Berlin Brandenburg Bremen Hamburg
                 Hessen Mecklenburg-Vorpommern Niedersachsen Nordrhein-Westfalen
                 Rheinland-Pfalz Saarland Sachsen Sachsen-Anhalt Schleswig-Holstein
                 Thüringen]

    csv = CSV.open('specimen_STU.csv', 'w+')

    csv << header_cells

    # Individuals in current project from Stuttgart
    Individual.includes(species: :family).in_project(5).where(herbarium_code: 'STU').find_each do |individual|
      line = []

      # Feldnummer
      if individual.collectors_field_number&.include?('s.n.') || individual.collectors_field_number&.include?('s. n.')
        line << ''
      else
        line << individual.collectors_field_number
      end

      line << individual.herbarium_code # Institut

      # Sammlungsnummer
      if individual.specimen_id == '<no info available in DNA Bank>'
        line << ''
      else
        line << individual.specimen_id
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
        if states.include? individual.state_province
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

      csv << line
    end
  end
end