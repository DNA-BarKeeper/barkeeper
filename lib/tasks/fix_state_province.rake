require 'net/http'
require 'nokogiri'


def get_state(i)
  if i.locality

    regex = /^([A-Za-z0-9\-]+)\..+/

    matches = i.locality.match(regex)
    if matches
      state_component = matches[1]

      i.update(:state_province => state_component)
    end
  end
end

namespace :data do

  desc "fix empty state-province from DNABank- import"

  task :fix_state_province => :environment do

    Individual.where(:state_province => nil).each do |i|

      get_state(i)

    end

    Individual.where(:state_province => "").each do |i|

      get_state(i)

    end
  end

end