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
end
