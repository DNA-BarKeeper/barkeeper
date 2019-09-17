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
