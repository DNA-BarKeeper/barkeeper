require 'net/http'
require 'nokogiri'


namespace :data do

  desc "Change precision of existing specimen location data records"

  task :change_location_data_precision => :environment do
    cnt = 0

    puts "Changing location data precision..."

    Individual.find_each(:batch_size => 50) do |individual|
      individual.update(:latitude => individual.latitude&.round(5))
      individual.update(:longitude => individual.longitude&.round(5))
      cnt += 1
    end

    puts "Done. Changed location data precision for #{cnt} records."
  end
end