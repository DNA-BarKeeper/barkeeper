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

  task import_db_gbol_assignments: :environment do
    cnt = 0
    not_found = 0

    Dir.foreach('db_gbol_assignments') do |item|
      next if File.directory?(item) # Also skips '.' and '..'
      next unless File.extname(item) == ".csv" # Read only CSV files

      CSV.foreach("db_gbol_assignments/#{item}", headers: true) do |row|
        gbol = row['Nr.']
        db = row['Isolate']

        if gbol && db
          isolate = Isolate.find_by("LOWER(lab_isolation_nr) = ?", gbol.downcase) # Case insensitive search
          not_found += 1 unless isolate
          cnt += 1 if isolate && !isolate.dna_bank_id
          isolate.update(dna_bank_id: db) if isolate && !isolate.dna_bank_id # Isolate was found and has no DB number yet
        end
      end
    end

    puts "#{cnt} DB numbers were assigned to isolates based on their GBOL numbers. #{not_found} Isolates could not be found in the database."
    puts "Done."
  end
end