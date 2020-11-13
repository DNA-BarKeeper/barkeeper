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
  task get_primer_by_isolate_list: :environment do
    isolate_file = File.open("isolate_list_dietmar.txt", 'r')
    isolates = isolate_file.readlines.map(&:chomp)
    isolates.delete('')
    isolates.delete(' ')

    CSV.open("primer_list.csv", 'w') do |csv|
      csv << ['isolate', 'primer read', 'primer']

      isolates.each do |isolate_name|
        isolate = Isolate.find_by_lab_isolation_nr(isolate_name)
        if isolate
          contigs = isolate.contigs.where(marker_id: 7) # trnK-matK

          contigs.each do |contig|
            contig.primer_reads.each do |read|
              csv << [isolate_name, read.name, read.primer&.name]
            end
          end
        end
      end
    end
  end
end