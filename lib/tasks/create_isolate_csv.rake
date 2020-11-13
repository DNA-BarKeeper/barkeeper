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
# frozen_string_literal: true

namespace :data do

  desc 'Creates csv with isolate gbol no, DB no, plate code and tube code'
  task create_isolate_csv: :environment do
    # Find all GBOL5 isolates belonging to Magnoliopsida
    isolates = Isolate.in_project(5).includes(:individual).joins(individual: [species: [family: [order: :higher_order_taxon]]])
                      .where(individual: { species: { family: { order: { higher_order_taxa: { id: 1 } } } } })
                      .order(:lab_isolation_nr)

    CSV.open('gbol_isolates_magnoliopsida.csv', 'wb') do |csv|
      csv << ['Lab isolation number', 'DNA Bank ID', 'Specimen', 'DNA G5o Plate (DNA)', 'DNA G5o Micronic tube ID',
              'Concentration copy (ng/µl)', 'DNA G5c Plate (DNA)', 'DNA G5c Micronic tube ID', 'Concentration copy (ng/µl)']

      isolates.each do |i|
        dna_plate_orig = MicronicPlate.find(i.micronic_plate_id_orig).micronic_plate_id unless i.micronic_plate_id_orig.blank?
        dna_plate_copy = MicronicPlate.find(i.micronic_plate_id_copy).micronic_plate_id unless i.micronic_plate_id_copy.blank?

        csv << [i.lab_isolation_nr, i.dna_bank_id, i.individual.specimen_id, dna_plate_orig, i.micronic_tube_id_orig, i.concentration_orig,
                dna_plate_copy, i.micronic_tube_id_copy, i.concentration_copy]
      end
    end
  end
end
