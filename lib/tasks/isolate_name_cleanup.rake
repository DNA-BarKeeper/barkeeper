namespace :data do
  task move_isolate_names_to_correct_fields: :environment do
    isolates = Isolate.where('lab_isolation_nr ilike ?', "DB%").where(dna_bank_id: ['', nil])
    isolates.all.each { |isolate| isolate.update(dna_bank_id: isolate.lab_isolation_nr) }
  end

  task find_duplicate_db_numbers: :environment do
    names_with_multiple = Isolate.group(:dna_bank_id).having('count(dna_bank_id) > 1').count.keys
    isolates = Isolate.where(dna_bank_id: names_with_multiple)

    #TODO: Maybe create CSV with GBOL numbers and/or other info for Berlin
    puts "#{isolates.size} Isolates with #{names_with_multiple.size} duplicate DNA Bank numbers were found."
  end
end