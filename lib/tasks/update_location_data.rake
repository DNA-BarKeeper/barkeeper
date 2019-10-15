# frozen_string_literal: true

require 'net/http'
require 'nokogiri'

namespace :data do
  desc 'Update Specimen Location Data'
  task update_location_data: :environment do
    spreadsheet = Roo::Excelx.new('/home/sarah/apps/gbol5/current/GBOL_2015_Koordinaten_Korrektur.xlsx')
    header = spreadsheet.row(1)
    no_specimen = []
    lat_cnt = 0
    long_cnt = 0

    puts 'Updating location data...'

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      isolate_lab_nr = row['GBoL Isolation No.']
      latitude = row['Latitude (calc.)']&.to_d
      longitude = row['Longitude (calc.)']&.to_d
      specimen = Individual.find_by_id(Isolate.where(lab_isolation_nr: isolate_lab_nr).first&.individual_id)

      if specimen
        if latitude&.nonzero? && specimen.latitude != latitude
          specimen.update(latitude: latitude)
          specimen.update(latitude_original: row['Latitude (calc.)'])
          lat_cnt += 1
        end

        if longitude&.nonzero? && specimen.longitude != longitude
          specimen.update(longitude: longitude)
          specimen.update(longitude_original: row['Longitude (calc.)'])
          long_cnt += 1
        end

        specimen.save!
      else
        no_specimen.push(isolate_lab_nr)
      end
    end

    puts "Done. Updated latitude data for #{lat_cnt} specimen and longitude data for #{long_cnt}."\
"\nNo specimens are assigned to the following #{no_specimen.length} isolates: #{no_specimen}"
  end

  task fix_coordinates: :environment do
    Individual.where(latitude_original: [' ']).update_all(latitude_original: '')
    Individual.where(longitude_original: [' ']).update_all(longitude_original: '')

    bad_latitude = Individual.bad_latitude
    bad_longitude = Individual.bad_longitude

    puts "Trying to correct #{bad_latitude.size} records with bad latitude."
    puts "Trying to correct #{bad_longitude.size} records with bad longitude."

    updated = 0

    bad_latitude.each do |ind|
      latitude = degree_to_decimal(ind.latitude_original.strip)
      latitude ||= north_east_to_decimal(ind.latitude_original.strip)

      puts ind.latitude_original
      puts latitude

      ind.update(latitude: latitude) if latitude
      updated += 1 if latitude
    end

    bad_longitude.each do |ind|
      longitude = degree_to_decimal(ind.longitude_original.strip)
      longitude ||= north_east_to_decimal(ind.longitude_original.strip)

      puts ind.longitude_original
      puts longitude

      ind.update(longitude: longitude) if longitude
      updated += 1 if longitude
    end

    puts "Done. Updated #{updated} coordinates."
  end

  desc "Strips state/province field of spaces"
  task strip_state_province: :environment do
    puts "Before stripping:"
    puts Individual.group(:state_province).order(:state_province).count
    puts ''

    individuals_space = Individual.where.not(state_province: nil).select { |i| i.state_province.match(/.+\s+\z/) }

    individuals_space.each do |individual|
      individual.update(state_province: individual.state_province.strip)
    end

    puts "After stripping:"
    puts Individual.group(:state_province).order(:state_province).count
  end

  desc "Replaces ü in state/province"
  task u_uml_state_province: :environment do
    puts "Before replacement:"
    puts Individual.group(:state_province).order(:state_province).count
    puts ''

    individuals_space = Individual.where.not(state_province: nil).select { |i| i.state_province.match(/.*\u0081.*/) }

    individuals_space.each do |individual|
      individual.update(state_province: individual.state_province.gsub("\u0081", "ü"))
    end

    puts "After replacement:"
    puts Individual.group(:state_province).order(:state_province).count
  end

  desc 'fix empty state-province from DNABank-import'
  task fix_state_province: :environment do
    Individual.where(state_province: ['', nil]).each do |individual|
      get_state(individual)
    end
  end

  desc "Fix java unicode characters in locality descriptions"
  task fix_locality: :environment do
    individuals = Individual.where('locality like ? OR locality like ? OR locality like ? OR locality like ?
OR locality like ? OR locality like ?', '%á%', '%„%', '%”%', '%Ž%', '%™%', '%š%')

    individuals_u_uml = Individual.where.not(locality: nil).select { |i| i.locality.match(/.*\u0081.*/) }

    puts "#{individuals.size} individuals with buggy unicode characters found."
    puts "#{individuals_u_uml.size} individuals with buggy ü found."

    puts 'Replacing special characters...'

    individuals.each do |ind|
      locality = ind.locality
                     .gsub('á', 'ß') # \u00E1
                     .gsub('„', 'ä') # \u0084
                     .gsub('”', 'ö') # \u0094
                     .gsub('Ž', 'Ä') # \u008e
                     .gsub('™', 'Ö') # \u0099
                     .gsub('š', 'Ü') # \u009A
      ind.update(locality: locality)
      ind.save
    end

    # Replace ü
    individuals_u_uml.each do |ind|
      ind.update(locality: ind.locality.gsub("\u0081", "ü"))
    end
  end

  task fix_country_languange: :environment do
    Individual.where(country: 'Frankreich').update_all(country: 'France')
    Individual.where(country: 'Sweden, Sterilkultur').update_all(country: 'Sweden')
    Individual.where(country: 'Schweden').update_all(country: 'Sweden')
    Individual.where(country: 'Belgien').update_all(country: 'Belgium')
    Individual.where(country: 'Schweiz').update_all(country: 'Switzerland')
    Individual.where(country: 'Schweiz').update_all(country: 'Switzerland')
    Individual.where(country: nil).update_all(country: '')
    Individual.where(country: ' -').update_all(country: '')
  end

  def get_state(i)
    if i.locality
      regex = /^([A-Za-z0-9\-]+)\..+/
      matches = i.locality.match(regex)
      if matches
        state_component = matches[1]
        i.update(state_province: state_component)
      end
    end
  end

  def degree_to_decimal(degree_string)
    locality_decimal = nil
    match = degree_string.match(/(\d+)°\s*(\d+)'\s*(\d+,*\d*)''/)
    match ||= degree_string.match(/(\d+)ø\s*(\d+)'\s*(\d+,*\d*)''/)
    match ||= degree_string.match(/(\d+)ø\s*(\d+)'\s*(\d+.*\d*)"/)

    if match
      locality_decimal = match[1].to_f + match[2].to_f/60 + match[3].gsub(',', '.').to_f/3600 if match
    else
      match = degree_string.match(/(\d+)°\s*(\d+)'[NE]/)
      locality_decimal = match[1].to_f + match[2].to_f/60 if match
    end

    locality_decimal
  end

  def north_east_to_decimal(degree_string)
    locality_decimal = nil
    match = degree_string.match(/(\d+,\d+).*/)

    locality_decimal = match[1].gsub(',', '.').to_f if match

    locality_decimal
  end
end
