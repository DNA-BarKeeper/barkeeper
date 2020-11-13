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
  task check_high_gbol_numbers: :environment do
    gbol_pattern = /[Gg][Bb][Oo][Ll](\d+)/

    gbol_numbers = Isolate.all.select(:lab_isolation_nr).map(&:lab_isolation_nr).collect { |nr| nr.match(gbol_pattern)[1] if nr.match(gbol_pattern) }

    gbol_numbers = gbol_numbers.map(&:to_i)

    high_numbers = gbol_numbers.select { |nr| nr > 10000 }.sort

    CSV.open("high_gbol_numbers.csv", 'w') do |file|
      file << ["GBOL number", "DNA Bank Number", "Specimen", "Species"]
      high_numbers.each do |high_number|
        isolate = Isolate.includes(individual: :species).where('lab_isolation_nr ilike ?', "gbol#{high_number}").first

        file << [isolate.lab_isolation_nr, isolate.dna_bank_id, isolate.individual&.specimen_id, isolate.individual&.species&.composed_name] if isolate
      end
    end
  end
end