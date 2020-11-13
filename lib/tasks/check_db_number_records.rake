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
  task check_db_number_records: :environment do
    isolates_sent_to_bonn = []

    Dir.foreach('sent_plates') do |item|
      next if File.directory?(item) # Also skips '.' and '..'

      CSV.foreach("sent_plates/#{item}", headers: true) do |row|
        isolates_sent_to_bonn << row['DNA Sample ID']
      end
    end

    isolates_sent_to_bonn = isolates_sent_to_bonn.flatten.collect { |id| id.downcase.gsub(' ', '') }.uniq

    puts "#{isolates_sent_to_bonn.size} unique Isolates were sent to Bonn."

    isolates_in_app = Isolate.in_project(5).map(&:dna_bank_id).compact.collect { |id| id.downcase.gsub(' ', '') }.uniq

    isolates_in_app = isolates_in_app & isolates_sent_to_bonn

    puts "#{isolates_in_app.size} of these Isolates were found in the web app."
    p isolates_in_app
  end
end