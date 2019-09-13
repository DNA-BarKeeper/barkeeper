namespace :data do
  task check_high_gbol_numbers: :environment do
    gbol_pattern = /[Gg][Bb][Oo][Ll](\d+)/

    gbol_numbers = Isolate.all.select(:lab_nr).map(&:lab_nr).collect { |nr| nr.match(gbol_pattern)[1] if nr.match(gbol_pattern) }

    gbol_numbers = gbol_numbers.map(&:to_i)

    high_numbers = gbol_numbers.select { |nr| nr > 10000 }.sort

    CSV.open("high_gbol_numbers.csv", 'w') do |file|
      file << ["GBOL number", "DNA Bank Number", "Specimen", "Species"]
      high_numbers.each do |high_number|
        isolate = Isolate.includes(individual: :species).where('lab_nr ilike ?', "gbol#{high_number}").first

        file << [isolate.lab_nr, isolate.dna_bank_id, isolate.individual&.specimen_id, isolate.individual&.species&.composed_name] if isolate
      end
    end
  end
end