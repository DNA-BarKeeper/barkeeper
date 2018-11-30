# frozen_string_literal: true

namespace :data do

  desc 'Creates csv with isolate gbol no, DB no, plate code and tube code'
  task create_isolate_csv: :environment do
    # Find all GBOL5 isolates belonging to Magnoliopsida
    isolates = Isolate.in_project(5).includes(:micronic_plate).joins(individual: [species: [family: [order: :higher_order_taxon]]])
                      .where(individual: { species: { family: { order: { higher_order_taxa: { id: 1 } } } } })

    CSV.open("gbol_isolates_magnoliopsida.csv", "wb") do |csv|
      csv << ["GBOL ID", "DB ID", "Plate ID", "Tube ID"]

      isolates.each do |i|
        csv << [i.lab_nr, i.dna_bank_id, i.micronic_plate_id, i.micronic_tube_id]
      end
    end
  end
end
