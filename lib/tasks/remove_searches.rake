require 'net/http'
require 'nokogiri'

namespace :data do

  desc "Remove untitled contig searches older than a month"
  task :remove_old_searches => :environment do
    ContigSearch.where("created_at < ?", 1.month.ago).where(:title => nil).delete_all
  end

  desc "Remove all untitled contig searches"
  task :remove_untitled_searches => :environment do
    ContigSearch.where(:title => nil).delete_all
  end

end