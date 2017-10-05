require 'net/http'
require 'nokogiri'

namespace :data do

  desc "Delete faulty primer reads and import them again correctly"

  task :reimport_chromatograms => :environment do
    nil_reads = PrimerRead.where(:sequence => nil)

    # download chromatograms of records without sequence
    nil_reads.each do |r|
      open(r.name, 'wb') do |file|
        file << open("http:#{r.chromatogram.url}").read
      end
    end

    # destroy all reads without sequence
    PrimerRead.where(:sequence => nil).destroy_all
  end
end